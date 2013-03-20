# ABSTRACT: Change the name of a stack

package Pinto::Action::Rename;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::Types qw(StackName StackObject);

#------------------------------------------------------------------------------

our $VERSION = '0.065_04'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Transactional );

#------------------------------------------------------------------------------

has from_stack => (
    is       => 'ro',
    isa      => StackName | StackObject,
    required => 1,
);


has to_stack => (
    is       => 'ro',
    isa      => StackName,
    required => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repo->get_stack($self->from_stack);

    $self->repo->rename_stack(stack => $stack, to => $self->to_stack);

    return $self->result->changed;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Rename - Change the name of a stack

=head1 VERSION

version 0.065_04

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut