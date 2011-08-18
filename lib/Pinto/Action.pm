package Pinto::Action;

# ABSTRACT: Base class for Actions

use Moose;
use Moose::Autobox;

use Carp;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.015'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has idxmgr => (
    is       => 'ro',
    isa      => 'Pinto::IndexManager',
    required => 1,
);

has store => (
    is       => 'ro',
    isa      => 'Pinto::Store',
    required => 1,
);

has messages => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    default    => sub{ [] },
    init_arg   => undef,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Methods

sub execute {
    my ($self) = @_;

    croak 'This is an absract method';
}

#------------------------------------------------------------------------------

sub add_message {
    my ($self, @messages) = @_;

    $self->messages()->push( @messages );

    return $self;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action - Base class for Actions

=head1 VERSION

version 0.015

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
