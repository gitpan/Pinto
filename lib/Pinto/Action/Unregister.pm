# ABSTRACT: Unregister packages from a stack

package Pinto::Action::Unregister;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Bool);
use MooseX::MarkAsMethods ( autoclean => 1 );

use Pinto::Util qw(throw);
use Pinto::Types qw(SpecList);

#------------------------------------------------------------------------------

our $VERSION = '0.087_04'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has targets => (
    isa      => SpecList,
    traits   => [qw(Array)],
    handles  => { targets => 'elements' },
    required => 1,
    coerce   => 1,
);

has force => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->stack;

    my @dists = map { $self->_unregister( $_, $stack ) } $self->targets;

    return @dists;
}

#------------------------------------------------------------------------------

sub _unregister {
    my ( $self, $target, $stack ) = @_;

    my $dist = $stack->get_distribution( spec => $target );

    throw "Target $target is not in the repository" if not defined $dist;

    $self->notice("Unregistering distribution $dist from stack $stack");

    my $did_unregister = $dist->unregister( stack => $stack, force => $self->force );

    return $did_unregister ? $dist : ();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Voss Jeff Karen Etheridge Michael G.
Schwern Bergsten-Buret Oleg Gashev Steffen Schwigon Wolfgang Kinkeldei
Yanick Champoux hesco Boris D�ppen Cory G Watson Glenn Fowler Jakob

=head1 NAME

Pinto::Action::Unregister - Unregister packages from a stack

=head1 VERSION

version 0.087_04

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
