	package Pinto::Action;

# ABSTRACT: Base class for Actions

use Moose;

use Carp;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.035'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has repos => (
    is       => 'ro',
    isa      => 'Pinto::Repository',
    required => 1,
);

has messages => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    traits     => [ 'Array' ],
    handles    => {add_message => 'push'},
    default    => sub{ [] },
    init_arg   => undef,
    auto_deref => 1,
);

has exceptions => (
    is         => 'ro',
    isa        => 'ArrayRef[Pinto::Exception]',
    traits     => [ 'Array' ],
    default    => sub{ [] },
    init_arg   => undef,
    handles    => {add_exception => 'push'},
    auto_deref => 1,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Interface::Configurable
         Pinto::Interface::Loggable );

#------------------------------------------------------------------------------
# Methods

sub execute {
    my ($self) = @_;
    croak 'This is an absract method';
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

version 0.035

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
