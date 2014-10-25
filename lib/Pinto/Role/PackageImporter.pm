package Pinto::Role::PackageImporter;

# ABSTRACT: Something that imports packages from another repository

use Moose::Role;

use Carp;
use Try::Tiny;

use Pinto::PackageExtractor;
use Pinto::Exceptions qw(throw_error);
use Pinto::PackageSpec;
use Pinto::Util;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.038'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has extractor => (
    is         => 'ro',
    isa        => 'Pinto::PackageExtractor',
    lazy_build => 1,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Loggable
         Pinto::Role::FileFetcher
);

#------------------------------------------------------------------------------
# Required interface

requires qw( repos );

#------------------------------------------------------------------------------
# Builders

sub _build_extractor {
    my ($self) = @_;

    return Pinto::PackageExtractor->new( config => $self->config(),
                                         logger => $self->logger() );
}

#------------------------------------------------------------------------------

sub find_or_import {
    my ($self, $target) = @_;

    if ( $target->isa('Pinto::PackageSpec') ){
        return $self->_import_by_package_spec($target);
    }
    elsif ($target->isa('Pinto::DistributionSpec') ){
        return $self->_import_by_distribution_spec($target);
    }
    else {
        my $type = ref $target;
        confess "Don't know how to import $type";
    }

}

#------------------------------------------------------------------------------

sub _import_by_package_spec {
    my ($self, $pspec) = @_;

    $self->info("Looking for package $pspec");
    my ($pkg_name, $pkg_ver) = ($pspec->name, $pspec->version);

    my $where   = {name => $pkg_name, is_latest => 1};
    my $got_pkg = $self->repos->select_packages( $where )->single();

    if ($got_pkg and $got_pkg->version() >= $pkg_ver) {
        $self->info("Already have package $pspec or newer as $got_pkg");
        return ($got_pkg->distribution(), 0);
    }

    my $dist_url = $self->repos->cache->locate( package => $pkg_name,
                                                version => $pkg_ver,
                                                latest  => 1 );
    if ($dist_url) {
        $self->debug("Found package $pspec or newer in $dist_url");

        if ( Pinto::Util::isa_perl($dist_url) ) {
            $self->debug("Distribution $dist_url is a perl.  Skipping it.");
            return;
        }

        return ($self->_import_distribution($dist_url), 1);
    }

    throw_error "Cannot find $pspec anywhere";

    return;
}

#------------------------------------------------------------------------------

sub _import_by_distribution_spec {
    my ($self, $dspec) = @_;

    $self->info("Looking for distribution $dspec");

    my $path     = $dspec->path;
    my $where    = {path => $path};
    my $got_dist = $self->repos->select_distributions( $where )->single();

    if ($got_dist) {
        $self->info("Already have distribution $dspec");
        return ($got_dist, 0);
    }

    my $dist_url = $self->repos->cache->locate( distribution => $path );

    if ($dist_url) {
        $self->debug("Found package $dspec at $dist_url");

        if ( Pinto::Util::isa_perl($dist_url) ) {
            $self->debug("Distribution $dist_url is a perl.  Skipping it.");
            return;
        }

        return ($self->_import_distribution($dist_url), 1);
    }

    throw_error "Cannot find $dspec anywhere";

    return;
}

#------------------------------------------------------------------------------

sub import_prerequisites {
    my ($self, $archive) = @_;

    my @prereq_queue = $self->_extract_prerequisites($archive);
    my %visited = ($archive => 1);
    my @imported;
    my %seen;

  PREREQ:
    while (my $prereq = shift @prereq_queue) {

        # my $queue_depth = @prereq_queue;
        # print "\nPrereq queue is $queue_depth deep:\n";
        # printf( "\t%s -> %s\n", $_->{name}, $_->{version} ) for sort {$a->{name} cmp $b->{name}} @prereq_queue;

        my ($required_dist, $imported_flag) = try {
              $self->find_or_import( $prereq );
        }
        catch {
             my $prereq_vname = "$prereq->{name}-$prereq->{version}";
             $self->error("Skipping prerequisite $prereq_vname. $_");
             # Mark the prereq as done so we don't try to import it again
             $seen{ $prereq->{name} } = $prereq;
             undef;  # returned by try{}
        };

        next PREREQ if not $required_dist;
        my $required_archive = $required_dist->archive( $self->config->root_dir() );
        push @imported, $required_dist if $imported_flag;

        if ( $visited{$required_archive} ) {
            # We don't need to extract prereqs from the same dist more than once
            $self->debug("Already visited archive $required_archive");
            next PREREQ;
        }

      NEW_PREREQ:
        for my $new_prereq ( $self->_extract_prerequisites($required_archive) ) {

            # This is all pretty hacky.  It might be better to represent the queue
            # as a hash table instead of a list, since we really need to keep track
            # of things by name.

            # Add this prereq to the queue only if greater than the ones we already got
            my $name = $new_prereq->{name};

            next NEW_PREREQ if exists $seen{$name}
                               && $new_prereq->{version} <= $seen{$name};


            # Take any prior versions of this prereq out of the queue
            @prereq_queue = grep { $_->{name} ne $name } @prereq_queue;

            # Note that this is the latest version of this prereq we've seen so far
            $seen{$name} = $new_prereq->{version};

            # Push the prereq onto the queue
            push @prereq_queue, $new_prereq;
        }

        $visited{$required_archive} = 1;
    }

    return @imported;
}

#------------------------------------------------------------------------------

sub _extract_prerequisites {
    my ($self, $archive) = @_;

    # If extraction fails, then just warn and return an empty list.  The
    # caller should just go on to the next archive.  The user will have
    # to figure out the prerequisites by other means.

    my @prereqs = try   { $self->extractor->requires( archive => $archive ) }
                  catch { $self->error("Unable to extract prerequisites from $archive: $_"); () };

    return map { Pinto::PackageSpec->new($_) } @prereqs;
}

#------------------------------------------------------------------------------

sub _import_distribution {
    my ($self, $url) = @_;

    my ($source, $path, $author, $destination) =
        Pinto::Util::parse_dist_url( $url, $self->config->root_dir() );

    my $where    = {path => $path};
    my $existing = $self->repos->select_distributions( $where )->single();
    throw_error "Distribution $path already exists" if $existing;

    $self->fetch(from => $url, to => $destination);

    my @pkg_specs = $self->extractor->provides(archive => $destination);
    $self->notice(sprintf "Importing distribution $url providing %d packages", scalar @pkg_specs);

    my $struct = { path     => $path,
                   source   => $source,
                   mtime    => Pinto::Util::mtime($destination),
                   packages => \@pkg_specs };

    my $dist = $self->repos->add_distribution($struct);

    return $dist;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::PackageImporter - Something that imports packages from another repository

=head1 VERSION

version 0.038

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
