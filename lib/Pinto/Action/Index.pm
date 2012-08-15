# ABSTRACT: Show the index of a stack

package Pinto::Action::Index;

use Moose;
use MooseX::Types::Moose qw(Undef HashRef Str Bool);

use Pinto::Types qw(Author StackName);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.048'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Reporter );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | Undef,
    default   => undef,
    coerce    => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->stack);
    $self->repos->write_index(stack => $stack, handle => $self->out);

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Index - Show the index of a stack

=head1 VERSION

version 0.048

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
