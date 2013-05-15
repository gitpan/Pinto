# ABSTRACT: Create a new stack by copying another

package Pinto::Action::Copy;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Bool Str);
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::Types qw(StackName StackObject);

#------------------------------------------------------------------------------

our $VERSION = '0.084'; # VERSION

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


has default => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);


has lock => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);


has description => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_description',
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my %changes = (name => $self->to_stack);
    my $orig    = $self->repo->get_stack($self->from_stack);
    my $copy    = $self->repo->copy_stack(stack => $orig, %changes);

    my $description = $self->has_description ? $self->description
                                             : "Copy of stack $orig";

    $copy->set_description($description);
    $copy->mark_as_default if $self->default;
    $copy->lock if $self->lock;

    return $self->result->changed;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Action::Copy - Create a new stack by copying another

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
