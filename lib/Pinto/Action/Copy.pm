# ABSTRACT: An action to create a new stack by copying another

package Pinto::Action::Copy;

use Moose;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_002'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Copy );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->from_stack);
    my $copy = $stack->copy_deeply({name => $self->to_stack});
    my $description = $self->description || "copy of stack $stack";
    $copy->set_property('description' => $description);
    $copy->touch($stack->last_modified_on);

    return $self->result->changed;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Copy - An action to create a new stack by copying another

=head1 VERSION

version 0.040_002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
