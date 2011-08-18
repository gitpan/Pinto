package Pinto::ActionFactory;

# ABSTRACT: Factory class for making Actions

use Moose;

use Class::Load;

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

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Methods

sub create_action {
    my ($self, $action_name, %args) = @_;

    my $action_class = "Pinto::Action::$action_name";
    Class::Load::load_class( $action_class );

    return $action_class->new( config => $self->config(),
                               logger => $self->logger(),
                               idxmgr => $self->idxmgr(),
                               store  => $self->store(),
                               %args );

}

#------------------------------------------------------------------------------

__PACKAGE__->meta()->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::ActionFactory - Factory class for making Actions

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
