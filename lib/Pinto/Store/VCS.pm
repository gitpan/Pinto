package Pinto::Store::VCS;

# ABSTRACT: Base class for VCS-backed Stores

use Moose;
use Moose::Autobox;

extends qw(Pinto::Store);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.018'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has _adds => (
    is          => 'ro',
    isa         => 'HashRef[Path::Class]',
    init_arg    => undef,
    default     => sub { {} },
);

has _deletes => (
    is          => 'ro',
    isa         => 'HashRef[Path::Class]',
    init_arg    => undef,
    default     => sub { {} },
);

has _mods => (
    is          => 'ro',
    isa         => 'HashRef[Path::Class]',
    init_arg    => undef,
    default     => sub { {} },
);

#------------------------------------------------------------------------------

# TODO: Figure out how to use a Set object and/or native trait
# delegation so that we don't have to write all these methods
# ourselves.

#------------------------------------------------------------------------------
# Methods

sub mark_path_as_added {
    my ($self, $path) = @_;

    $self->_adds->put($path->stringify(), $path);

    return $self;
}

#------------------------------------------------------------------------------

sub mark_path_as_removed {
    my ($self, $path) = @_;

    $self->_deletes->put($path->stringify(), $path);

    return $self;
}

#------------------------------------------------------------------------------

sub mark_path_as_modified {
    my ($self, $path) = @_;

    $self->_mods->put($path->stringify(), $path);

    return $self;
}

#------------------------------------------------------------------------------

sub added_paths {
    my ($self) = @_;

    return $self->_adds->values->sort->flatten();
}

#------------------------------------------------------------------------------

sub removed_paths {
    my ($self) = @_;

    return $self->_deletes->values->sort->flatten();
}

#------------------------------------------------------------------------------

sub modified_paths {
    my ($self) = @_;

    return $self->_mods->values->sort->flatten();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store::VCS - Base class for VCS-backed Stores

=head1 VERSION

version 0.018

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

