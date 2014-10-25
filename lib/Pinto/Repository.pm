# ABSTRACT: Coordinates the database, files, and indexes

package Pinto::Repository;

use Moose;

use Pinto::Store;
use Pinto::Locker;
use Pinto::Database;
use Pinto::IndexCache;
use Pinto::PackageExtractor;
use Pinto::Exception qw(throw);
use Pinto::Types qw(Dir);

use namespace::autoclean;

#-------------------------------------------------------------------------------

our $VERSION = '0.040_002'; # VERSION

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
    handles    => [ qw(lock unlock) ],
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
        return $latest ? $latest : ();
    }
}

#-------------------------------------------------------------------------------


sub get_distribution {
    my ($self, %args) = @_;

    my $dist_path = $args{path};

    my $where = { path => $dist_path };
    my $attrs = { prefetch => 'packages' };
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

    my $basename   = $archive->basename();
    my $author_dir = Pinto::Util::author_dir($author);
    my $dist_path  = $author_dir->file($basename)->as_foreign('Unix')->stringify();

    $self->get_distribution(path => $dist_path)
        and throw "Distribution $dist_path already exists";

    # Assemble the basic structure...
    my $dist_struct = { path     => $dist_path,
                        source   => $source,
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
    $self->info("Archvie $dist_path provides $p and requires $r packages");

    # Always update database *before* moving the archive into the
    # repository, so if there is an error in the DB, we can stop and
    # the repository will still be clean.

    my $dist = $self->db->create_distribution( $dist_struct );
    my $repo_archive = $dist->archive( $self->root_dir() );
    $self->fetch( from => $archive, to => $repo_archive );
    $self->store->add_archive( $repo_archive );

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

version 0.040_002

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

=head2 lock

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

=head2 get_distribution( path => $dist_path )

Returns the L<Pinto::Schema::Result::Distribution> with the given
C<$dist_path>.  If there is no distribution with such a path in the
respoistory, returns nothing.  Note the C<$dist_path> is a Unix-style
path fragment that identifies the location of the distribution archive
within the repository, such as F<J/JE/JEFF/Pinto-0.033.tar.gz>

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
