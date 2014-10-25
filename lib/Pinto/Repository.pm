# ABSTRACT: Coordinates the database, files, and indexes

package Pinto::Repository;

use Moose;

use Pinto::Util;
use Pinto::Store;
use Pinto::Locker;
use Pinto::Database;
use Pinto::IndexCache;
use Pinto::PackageExtractor;
use Pinto::Exception qw(throw);
use Pinto::Types qw(Dir);

use namespace::autoclean;

#-------------------------------------------------------------------------------

our $VERSION = '0.044'; # VERSION

#-------------------------------------------------------------------------------

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable
         Pinto::Role::FileFetcher );

#-------------------------------------------------------------------------------


has db => (
    is         => 'ro',
    isa        => 'Pinto::Database',
    lazy       => 1,
    default    => sub { Pinto::Database->new( config => $_[0]->config,
                                              logger => $_[0]->logger ) },
);



has store => (
    is         => 'ro',
    isa        => 'Pinto::Store',
    lazy       => 1,
    handles    => [ qw(initialize commit tag) ],
    default    => sub { Pinto::Store->new( config => $_[0]->config,
                                           logger => $_[0]->logger ) },
);


has cache => (
    is         => 'ro',
    isa        => 'Pinto::IndexCache',
    lazy       => 1,
    handles    => [ qw(locate) ],
    clearer    => 'clear_cache',
    default    => sub { Pinto::IndexCache->new( config => $_[0]->config,
                                                logger => $_[0]->logger ) },
);


has locker  => (
    is         => 'ro',
    isa        => 'Pinto::Locker',
    lazy       => 1,
    handles    => { lock_exclusive => [lock => 'EX'],
                    lock_shared    => [lock => 'SH'],
                    unlock         => 'unlock' },
    default    => sub { Pinto::Locker->new( config => $_[0]->config,
                                            logger => $_[0]->logger ) },
);


has extractor => (
    is         => 'ro',
    isa        => 'Pinto::PackageExtractor',
    lazy       => 1,
    default    => sub { Pinto::PackageExtractor->new( config => $_[0]->config,
                                                      logger => $_[0]->logger ) },
);

#-------------------------------------------------------------------------------

sub BUILD {
    my ($self) = @_;

    unless (    -e $self->config->db_file
             && -e $self->config->modules_dir
             && -e $self->config->authors_dir ) {

        my $root_dir = $self->config->root_dir();
        throw "Directory $root_dir does not look like a Pinto repository";
    }

    return $self;
}

#-------------------------------------------------------------------------------

sub check_schema_version {
    my ($self) = @_;

    my $class_schema_version = $Pinto::Schema::SCHEMA_VERSION;
    my $db_schema_version = $self->get_property('pinto:schema_version');

    throw "Could not find the version of this repository"
      if not defined $db_schema_version;

    throw "Your repository is too old for this version of Pinto"
      if $class_schema_version > $db_schema_version;

    throw "This version of Pinto is too old for this repository"
      if $class_schema_version < $db_schema_version;

    return;
}

#-------------------------------------------------------------------------------

sub get_property {
    my ($self, @prop_names) = @_;

    my %props = %{ $self->get_properties };
    return @props{@prop_names};
}

#-------------------------------------------------------------------------------

sub get_properties {
    my ($self) = @_;

    my @props = $self->db->repository_properties->search->all;

    return { map { $_->name => $_->value } @props };
}

#-------------------------------------------------------------------------------

sub set_property {
    my ($self, $prop_name, $value) = @_;
    return $self->set_properties( {$prop_name => $value} );
}

#-------------------------------------------------------------------------------

sub set_properties {
    my ($self, $props) = @_;

    while (my ($name, $value) = each %{$props}) {
        $name = Pinto::Util::normalize_property_name($name);
        my $nv_pair = {name => $name, value => $value};
        $self->db->repository_properties->update_or_create($nv_pair);
    }

    return $self;
}

#-------------------------------------------------------------------------------

sub delete_property {
    my ($self, @prop_names) = @_;

    for my $prop_name (@prop_names) {
        my $where = {name => $prop_name};
        my $prop = $self->db->repository_properties->update_or_create($where);
        $prop->delete if $prop;
    }

    return $self;
}

#-------------------------------------------------------------------------------

sub delete_properties {
    my ($self) = @_;

    my $props_rs = $self->db->repository_properties->search;
    $props_rs->delete;

    return $self;
}

#-------------------------------------------------------------------------------


sub get_stack {
    my ($self, %args) = @_;

    my $stk_name = $args{name};
    return $stk_name if ref $stk_name;  # Is object (or struct) so just return
    return $self->get_default_stack if not $stk_name;

    my $where = { name => $stk_name };
    my $stack = $self->db->select_stack( $where );

    throw "Stack $stk_name does not exist"
        unless $stack or $args{nocroak};

    return $stack;
}

#-------------------------------------------------------------------------------


sub get_default_stack {
    my ($self) = @_;

    my $where = {is_default => 1};
    my @stacks = $self->db->select_stacks( $where )->all;

    throw "PANIC! There must be exactly one default stack" if @stacks != 1;

    return $stacks[0];
}

#-------------------------------------------------------------------------------


sub get_package {
    my ($self, %args) = @_;

    my $pkg_name = $args{name};
    my $pkg_vers = $args{version}; # ??
    my $stk_name = $args{stack};

    if ($stk_name) {
        my $stack = $self->get_stack(name => $stk_name);
        my $attrs = { prefetch => 'package' };
        my $where = { package_name => $pkg_name, stack => $stack->id };
        my $registration = $self->db->select_registration($where, $attrs);
        return $registration ? $registration->package : ();
    }
    else {
        my $where  = { name => $pkg_name };
        my @pkgs   = $self->db->select_packages( $where )->all;
        my $latest = (sort {$a <=> $b} @pkgs)[-1];
        return defined $latest ? $latest : ();
    }
}

#-------------------------------------------------------------------------------


sub get_distribution {
    my ($self, %args) = @_;

    my $attrs = { prefetch => 'packages' };
    my $where = { author => $args{author}, archive => $args{archive} };
    my $dist  = $self->db->select_distributions( $where, $attrs )->first;

    return $dist;
}

#-------------------------------------------------------------------------------


sub add {
    my ($self, %args) = @_;

    my $archive = $args{archive};
    my $author  = $args{author};
    my $source  = $args{source} || 'LOCAL';
    my $index   = $args{index}  || 1;  # Is this needed?

    throw "Archive $archive does not exist"  if not -e $archive;
    throw "Archive $archive is not readable" if not -r $archive;

    my $archive_basename = $archive->basename;
    my $dist_pretty      = "$author/$archive_basename";

    $self->get_distribution(author => $author, archive => $archive_basename)
        and throw "Distribution $dist_pretty already exists";

    # Assemble the basic structure...
    my $dist_struct = { author   => $author,
                        source   => $source,
                        archive  => $archive_basename,
                        mtime    => Pinto::Util::mtime($archive),
                        md5      => Pinto::Util::md5($archive),
                        sha256   => Pinto::Util::sha256($archive) };

    # Add provided packages...
    my @provides = $self->extractor->provides( archive => $archive );
    $dist_struct->{packages} = \@provides;

    # Add required packages...
    my @requires = $self->extractor->requires( archive => $archive );
    $dist_struct->{prerequisites} = \@requires;

    my $p = @provides;
    my $r = @requires;
    $self->info("Distribution $dist_pretty provides $p and requires $r packages");

    # Always update database *before* moving the archive into the
    # repository, so if there is an error in the DB, we can stop and
    # the repository will still be clean.

    my $dist = $self->db->create_distribution( $dist_struct );
    my $archive_in_repos = $dist->native_path( $self->root_dir );
    $self->fetch( from => $archive, to => $archive_in_repos );
    $self->store->add_archive( $archive_in_repos );

    return $dist;
}

#------------------------------------------------------------------------------


sub pull {
    my ($self, %args) = @_;

    my $url = $args{url};
    my ($source, $path, $author) = Pinto::Util::parse_dist_url( $url );

    throw "Distribution $path already exists"
        if $self->get_distribution( path => $path );

    my $archive = $self->fetch_temporary(url => $url);

    my $dist = $self->add( archive   => $archive,
                           author    => $author,
                           source    => $source );
    return $dist;
}

#------------------------------------------------------------------------------

sub get_or_pull {
    my ($self, %args) = @_;

    my $target = $args{target};
    my $stack  = $args{stack};

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
    my $latest = $self->get_package(name => $pkg_name);

    if (defined $latest && ($latest->version >= $pkg_ver)) {
        my $dist = $latest->distribution;
        $self->debug( sub {"Already have package $pspec or newer as $latest"} );
        my $did_register = $dist->register(stack => $stack);
        return ($dist, $did_register);
    }

    my $dist_url = $self->locate( package => $pspec->name,
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
    my $dist = $self->pull(url => $dist_url);

    $dist->register( stack => $stack );

    return ($dist, 1);
}

#------------------------------------------------------------------------------

sub _pull_by_distribution_spec {
    my ($self, $dspec, $stack) = @_;

    $self->info("Looking for distribution $dspec");

    my $got_dist = $self->get_distribution( author  => $dspec->author,
                                            archive => $dspec->archive );

    if ($got_dist) {
        $self->info("Already have distribution $dspec");
        my $did_register = $got_dist->register(stack => $stack);
        return ($got_dist, $did_register);
    }

    my $dist_url = $self->locate(distribution => $dspec->path)
      or throw "Cannot find prerequisite $dspec anywhere";

    $self->debug("Found package $dspec at $dist_url");

    if ( Pinto::Util::isa_perl($dist_url) ) {
        $self->debug("Distribution $dist_url is a perl. Skipping it.");
        return (undef , 0);
    }

    $self->notice("Pulling distribution $dist_url");
    my $dist = $self->pull(url => $dist_url);

    $dist->register( stack => $stack );

    return ($dist, 1);
}

#------------------------------------------------------------------------------

sub pull_prerequisites {
    my ($self, %args) = @_;

    my $dist  = $args{dist};
    my $stack = $args{stack};

    my @prereq_queue = $dist->prerequisite_specs;
    my %visited = ($dist->path => 1);
    my @pulled;
    my %seen;

  PREREQ:
    while (my $prereq = shift @prereq_queue) {

        my ($required_dist, $did_pull) = $self->get_or_pull( target => $prereq,
                                                             stack  => $stack );
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

#-------------------------------------------------------------------------------


sub create_stack {
    my ($self, %args) = @_;

    my $name  = Pinto::Util::normalize_stack_name($args{name});
    my $props = $args{properties};

    throw "Stack $name already exists"
        if $self->get_stack(name => $name, nocroak => 1);

    my $stack = $self->db->create_stack( {name => $name} );
    $stack->set_properties($props) if $props;

    return $stack;

}

#-------------------------------------------------------------------------------

sub write_index {
    my ($self, %args) = @_;

    my $writer = Pinto::IndexWriter->new(logger => $self->logger);

    $args{file}  ||= $self->config->index_file unless $args{handle};
    $args{stack} ||= $self->get_default_stack;

    $writer->write(%args);

    return $self;
}

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Repository - Coordinates the database, files, and indexes

=head1 VERSION

version 0.044

=head1 ATTRIBUTES

=head2 db

=head2 store

=head2 cache

=head2 extractor

=head1 METHODS

=head2 initialize()

=head2 commit()

=head2 tag()

=head2 locate( package => );

=head2 locate( distribution => );

=head2 lock_shared

=head2 lock_exclusive

=head2 unlock

=head2 get_stack()

=head2 get_stack( name => $stack_name )

=head2 get_stack( name => $stack_name, nocroak => 1 )

Returns the L<Pinto::Schema::Result::Stack> object with the given
C<$stack_name>.  If there is no stack with such a name in the
repository, throws an exception.  If the C<nocroak> option is true,
than an exception will not be thrown and undef will be returned.  If
you do not specify a stack name (or it is undefined) then you'll get
whatever stack is currently marked as the default stack.

=head2 get_default_stack()

Returns the L<Pinto::Schema::Result::Stack> that is currently marked
as the default stack in this repository.  This is what you get when you
call C<get_stack> without any arguments.

At any time, there must be exactly one default stack.  This method will
throw an exception if it discovers that condition is not true.

=head2 get_package( name => $pkg_name )

Returns the latest version of L<Pinto:Schema::Result::Package> with
the given C<$pkg_name>.  If there is no such package with that name in the
repository, returns nothing.

=head2 get_package( name => $pkg_name, stack => $stk_name )

Returns the L<Pinto:Schema::Result::Package> with the given
C<$pkg_name> that is on the stack with the given C<$stk_name>. If
there is no such package on that stack, returns nothing.

=head2 get_distribution( author => $author, archive => $archive )

Returns the L<Pinto::Schema::Result::Distribution> with the given
author ID and archive name.  If there is no distribution in the
respoistory, returns nothing.

=head2 add( archive => $path, author => $id )

=head2 add( archive => $path, author => $id, source => $url )

Adds the distribution archive located on the local filesystem at
C<$path> to the repository in the author directory for the author with
C<$id>.  The packages provided by the distribution will be indexed,
and the prerequisites will be recorded.  If the the C<source> is
specified, it must be the URL to the root of the repository where the
distribution came from.  Otherwise, the C<source> defaults to
C<LOCAL>.  Returns a L<Pinto::Schema::Result::Distribution> object
representing the newly added distribution.

=head2 pull( url => $url )

Pulls a distribution archive from a remote repository and C<add>s it
to this repository.  The packages provided by the distribution will be
indexed, and the prerequisites will be recorded.  Returns a
L<Pinto::Schema::Result::Distribution> object representing the newly
pulled distribution.

=head2 pull( package => $spec )

=head2 pull( distribution => $spec )

=head2 create_stack(name => $stk_name, properties => { $key => $value, ... } )

=head2 locate(path = $dist_path)

=head2 locate(package => $name)

=head2 locate(package => $name, version => $vers)

=head2 get_or_locate(path = $dist_path)

=head2 get_or_locate(package => $name)

=head2 get_or_locate(package => $name, version => $vers)

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
