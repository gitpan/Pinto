# ABSTRACT: Something that imports packages from another repository

package Pinto::Role::PackageImporter;

use Moose::Role;

use Pinto::Util;
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_003'; # VERSION

#------------------------------------------------------------------------------

with qw( Pinto::Role::Loggable
         Pinto::Role::FileFetcher );

#------------------------------------------------------------------------------
# Required interface

requires qw( repos );

#------------------------------------------------------------------------------

sub find_or_pull {
    my ($self, $target, $stack) = @_;

    if ( $target->isa('Pinto::PackageSpec') ){
        return $self->_pull_by_package_spec($target, $stack);
    }
    elsif ($target->isa('Pinto::DistributionSpec') ){
        return $self->_pull_by_distribution_spec($target, $stack);
    }
    else {
        my $type = ref $target;
        throw "Don't know how to pull a $type";
    }

}

#------------------------------------------------------------------------------

sub _pull_by_package_spec {
    my ($self, $pspec, $stack) = @_;

    $self->info("Looking for package $pspec");

    my ($pkg_name, $pkg_ver) = ($pspec->name, $pspec->version);
    my $latest = $self->repos->get_package(name => $pkg_name);

    if ($latest && $latest->version >= $pkg_ver) {
        my $dist = $latest->distribution;
        $self->debug("Already have package $pspec or newer as $latest");
        $dist->register(stack => $stack);
        return ($dist, 0);
    }

    my $dist_url = $self->repos->locate( package => $pspec->name,
                                         version => $pspec->version,
                                         latest  => 1 );

    throw "Cannot find prerequisite $pspec anywhere"
      if not $dist_url;

    $self->debug("Found package $pspec or newer in $dist_url");

    if ( Pinto::Util::isa_perl($dist_url) ) {
        $self->debug("Distribution $dist_url is a perl. Skipping it.");
        return (undef, 0);
    }

    $self->notice("Pulling distribution $dist_url");
    my $dist = $self->repos->pull(url => $dist_url);

    $dist->register( stack => $stack );

    return ($dist, 1);
}

#------------------------------------------------------------------------------

sub _pull_by_distribution_spec {
    my ($self, $dspec, $stack) = @_;

    $self->info("Looking for distribution $dspec");

    my $path     = $dspec->path;
    my $got_dist = $self->repos->get_distribution(path => $path);

    if ($got_dist) {
        $self->info("Already have distribution $dspec");
        $got_dist->register(stack => $stack);
        return ($got_dist, 0);
    }

    my $dist_url = $self->repos->locate(distribution => $dspec->path)
      or throw "Cannot find prerequisite $dspec anywhere";

    $self->debug("Found package $dspec at $dist_url");

    if ( Pinto::Util::isa_perl($dist_url) ) {
        $self->debug("Distribution $dist_url is a perl. Skipping it.");
        return (undef , 0);
    }

    $self->notice("Pulling distribution $dist_url");
    my $dist = $self->repos->pull(url => $dist_url);

    $dist->register( stack => $stack );

    return ($dist, 1);
}

#------------------------------------------------------------------------------

sub pull_prerequisites {
    my ($self, $dist, $stack) = @_;

    my @prereq_queue = $dist->prerequisite_specs;
    my %visited = ($dist->path => 1);
    my @pulled;
    my %seen;

  PREREQ:
    while (my $prereq = shift @prereq_queue) {

        my ($required_dist, $did_pull) = $self->find_or_pull($prereq, $stack);
        next PREREQ if not ($required_dist and $did_pull);
        push @pulled, $required_dist if $did_pull;

        if ( $visited{$required_dist->path} ) {
            # We don't need to recurse into prereqs more than once
            $self->debug("Already visited archive $required_dist");
            next PREREQ;
        }

      NEW_PREREQ:
        for my $new_prereq ( $required_dist->prerequisite_specs ) {

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

        $visited{$required_dist->path} = 1;
    }

    return @pulled;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::PackageImporter - Something that imports packages from another repository

=head1 VERSION

version 0.040_003

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
