# ABSTRACT: Loosen a package that has been pinned

package Pinto::Action::Unpin;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::Util qw(throw);
use Pinto::Types qw(SpecList);

#------------------------------------------------------------------------------

our $VERSION = '0.084'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has targets => (
    isa      => SpecList,
    traits   => [ qw(Array) ],
    handles  => {targets => 'elements'},
    required => 1,
    coerce   => 1,
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->stack;

    my @dists = map { $self->_unpin($_, $stack) } $self->targets;

    return @dists;
}

#------------------------------------------------------------------------------

sub _unpin {
    my ($self, $target, $stack) = @_;

    my $dist = $stack->get_distribution(spec => $target);

    throw "$target is not registered on stack $stack" if not defined $dist;

    $self->notice("Unpinning distribution $dist from stack $stack");

    my $did_unpin = $dist->unpin(stack => $stack);

    $self->warning("Distribution $dist is not pinned to stack $stack") unless $did_unpin;

    return $did_unpin ? $dist : ();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Action::Unpin - Loosen a package that has been pinned

=head1 VERSION

version 0.084

=head1 CONTRIBUTORS

=over 4

=item *

Cory G Watson <gphat@onemogin.com>

=item *

Jakob Voss <jakob@nichtich.de>

=item *

Jeff <jeff@callahan.local>

=item *

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=item *

Jeffrey Thalhammer <jeff@imaginative-software.com>

=item *

Karen Etheridge <ether@cpan.org>

=item *

Michael G. Schwern <schwern@pobox.com>

=item *

Steffen Schwigon <ss5@renormalist.net>

=item *

Wolfgang Kinkeldei <wolfgang@kinkeldei.de>

=item *

Yanick Champoux <yanick@babyl.dyndns.org>

=item *

hesco <hesco@campaignfoundations.com>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
