package Pinto::IndexManager;

# ABSTRACT: Manages the indexes of a Pinto repository

use Moose;
use Moose::Autobox;

use Carp;
use Path::Class;

use Pinto::Util;
use Pinto::Index;
use Pinto::UserAgent;

#-----------------------------------------------------------------------------

our $VERSION = '0.008'; # VERSION

#-----------------------------------------------------------------------------

has 'ua'  => (
    is         => 'ro',
    isa        => 'Pinto::UserAgent',
    default    => sub { Pinto::UserAgent->new() },
    handles    => [qw(mirror)],
    init_arg   => undef,
);

#-----------------------------------------------------------------------------


has 'mirror_index' => (
    is             => 'ro',
    isa            => 'Pinto::Index',
    builder        => '__build_mirror_index',
    init_arg       => undef,
    lazy           => 1,
);


has 'local_index'   => (
    is              => 'ro',
    isa             => 'Pinto::Index',
    builder         => '__build_local_index',
    init_arg        => undef,
    lazy            => 1,
);


has 'master_index'  => (
    is              => 'ro',
    isa             => 'Pinto::Index',
    builder         => '__build_master_index',
    init_arg        => undef,
    lazy            => 1,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Builders

sub __build_mirror_index {
    my ($self) = @_;

    return $self->__build_index(file => '02packages.details.mirror.txt.gz');
}

#------------------------------------------------------------------------------

sub __build_local_index {
    my ($self) = @_;

    return $self->__build_index(file => '02packages.details.local.txt.gz');
}

#------------------------------------------------------------------------------

sub __build_master_index {
    my ($self) = @_;

    return $self->__build_index(file => '02packages.details.txt.gz');
}

#------------------------------------------------------------------------------

sub __build_index {
    my ($self, %args) = @_;

    my $local = $self->config->local();
    my $index_file = Path::Class::file($local, 'modules', $args{file});

    return Pinto::Index->new( logger => $self->logger(),
                              file   => $index_file );
}

#------------------------------------------------------------------------------

sub update_mirror_index {
    my ($self) = @_;

    my $local  = $self->config->local();
    my $mirror = $self->config->mirror();

    my $mirror_index_uri = URI->new("$mirror/modules/02packages.details.txt.gz");
    my $mirrored_file = Path::Class::file($local, 'modules', '02packages.details.mirror.txt.gz');
    my $file_has_changed = $self->ua->mirror(url => $mirror_index_uri, to => $mirrored_file);
    $self->mirror_index->reload() if $file_has_changed or $self->config->force();

    return $file_has_changed or $self->config->force();
}

#------------------------------------------------------------------------------

sub dists_to_mirror {
    my ($self) = @_;

    my $temp_index = Pinto::Index->new();
    $temp_index->add( $self->mirror_index->packages->values->flatten() );
    $temp_index->add( $self->local_index->packages->values->flatten() );

    my $sorter = sub { $_[0]->location() cmp $_[1]->location() };
    return $temp_index->distributions->values->sort($sorter)->flatten();
}

#------------------------------------------------------------------------------

sub all_packages {
    my ($self) = @_;

    my $sorter = sub { $_[0]->name() cmp $_[1]->name() };
    return $self->master_index->packages->values->sort($sorter)->flatten();
  }

#------------------------------------------------------------------------------

sub write_indexes {
    my ($self) = @_;

    $self->local_index->write();
    $self->master_index->write();

    return $self;
}

#------------------------------------------------------------------------------

sub rebuild_master_index {
    my ($self) = @_;

    $DB::single = 1;
    $self->master_index->clear();
    $self->master_index->add( $self->mirror_index->packages->values->flatten() );
    $self->master_index->add( $self->local_index->packages->values->flatten() );

    return $self;
}

#------------------------------------------------------------------------------

sub remove_local_package {
    my ($self, %args) = @_;

    my $package = $args{package};
    my $author  = $args{author};

    my $orig_author = $self->local_author_of(package => $package);
    croak "You are $author, but only $orig_author can remove $package"
        if defined $orig_author and $author ne $orig_author;

    my $local_dist = ( $self->local_index->remove($package) )[0];
    return if not $local_dist;

    $self->logger->debug("Removed $local_dist from local index");

    my $master_dist = ( $self->master_index->remove($package) )[0];
    $self->logger->debug("Removed $master_dist from master index");

    $self->rebuild_master_index();

    return $local_dist;
}

#------------------------------------------------------------------------------

sub local_author_of {
    my ($self, %args) = @_;

    my $package = $args{package};
    $package = $package->name() if eval {$package->isa('Pinto::Package')};

    my $pkg = $self->local_index->packages->at($package);

    return if not $pkg;
    return $pkg->dist->author();
}

#------------------------------------------------------------------------------

sub add_mirrored_distribution {
    my ($self, %args) = @_;

    my $dist = $args{dist};
    my @packages = $dist->packages->flatten();
    my @removed_dists = $self->master_index->add( @packages );

    return @removed_dists;
}

#------------------------------------------------------------------------------

sub add_local_distribution {
    my ($self, %args) = @_;

    my $dist = $args{dist};

    croak 'A distribution already exists at ' . $dist->location()
        if $self->master_index->distributions->at( $dist->location() );

    my @packages = $dist->packages->flatten();
    for my $pkg ( @packages ) {
        if ( my $orig_author = $self->local_author_of(package => $pkg) ) {
            croak sprintf "Package %s is owned by $orig_author", $pkg->name()
              if $orig_author ne $dist->author();
        }
    }

    my @removed_dists = $self->local_index->add(@packages);
    $self->rebuild_master_index();

    return @removed_dists;

}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::IndexManager - Manages the indexes of a Pinto repository

=head1 VERSION

version 0.008

=head1 ATTRIBUTES

=head2 mirror_index

Returns the L<Pinto::Index> that represents our copy of the
F<02packages> file from a CPAN mirror (or possibly another Pinto
repository).  This index will include the latest versions of all the
packages on the mirror.

=head2 local_index

Returns the L<Pinto::Index> that represents the F<02packages> file for
your local packages.  This index will include only those packages that
you've locally added to the repository.

=head2 master_index

Returns the L<Pinto::Index> that is the logical combination of
packages from both the mirror and local indexes.  See the L<"RULES">
section below for information on how the indexes are combined.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
