# ABSTRACT: Register packages from existing archives on a stack

package Pinto::Action::Register;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Bool);
use MooseX::MarkAsMethods ( autoclean => 1 );

use Pinto::Util qw(throw);
use Pinto::Types qw(DistSpecList);

#------------------------------------------------------------------------------

our $VERSION = '0.091'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has targets => (
    isa      => DistSpecList,
    traits   => [qw(Array)],
    handles  => { targets => 'elements' },
    required => 1,
    coerce   => 1,
);

has pin => (
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

    my @dists = map { $self->_register( $_, $stack ) } $self->targets;

    return @dists;
}

#------------------------------------------------------------------------------

sub _register {
    my ( $self, $spec, $stack ) = @_;

    my $dist = $self->repo->get_distribution( spec => $spec );

    throw "Distribution $spec is not in the repository" if not defined $dist;

    $self->notice("Registering distribution $dist on stack $stack");

    my $did_register = $dist->register( stack => $stack, pin => $self->pin );

    return $did_register ? $dist : ();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=encoding utf-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux hesco popl Däppen Cory G Watson
David Steinbrunner Glenn

=head1 NAME

Pinto::Action::Register - Register packages from existing archives on a stack

=head1 VERSION

version 0.091

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
