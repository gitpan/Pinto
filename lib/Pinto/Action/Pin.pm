# ABSTRACT: Force a package to stay in a stack

package Pinto::Action::Pin;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods ( autoclean => 1 );

use Pinto::Util qw(throw);
use Pinto::Types qw(TargetList);

#------------------------------------------------------------------------------

our $VERSION = '0.0994_03'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has targets => (
    isa      => TargetList,
    traits   => [qw(Array)],
    handles  => { targets => 'elements' },
    required => 1,
    coerce   => 1,
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->stack;

    my @dists = map { $self->_pin( $_, $stack ) } $self->targets;

    return @dists;
}

#------------------------------------------------------------------------------

sub _pin {
    my ( $self, $target, $stack ) = @_;

    my $dist = $stack->get_distribution( target => $target );

    throw "$target is not registered on stack $stack" if not defined $dist;

    $self->notice("Pinning distribution $dist to stack $stack");

    my $did_pin = $dist->pin( stack => $stack );

    $self->warning("Distribution $dist is already pinned to stack $stack") unless $did_pin;

    return $did_pin ? $dist : ();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux brian d foy hesco popl Däppen Cory
G Watson David Steinbrunner Glenn

=head1 NAME

Pinto::Action::Pin - Force a package to stay in a stack

=head1 VERSION

version 0.0994_03

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
