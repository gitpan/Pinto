# ABSTRACT: Show the difference between two stacks

package Pinto::Action::Diff;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::Difference;
use Pinto::Constants qw(:color);
use Pinto::Types qw(StackName StackDefault StackObject RevisionID);

#------------------------------------------------------------------------------

our $VERSION = '0.080'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has left_stack => (
    is       => 'ro',
    isa      => StackName | StackDefault | StackObject,
    default  => undef,
);


has right_stack => (
    is       => 'ro',
    isa      => StackName | StackObject,
    required => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $left  = $self->repo->get_stack($self->left_stack);
    my $right = $self->repo->get_stack($self->right_stack);
    my $diff  = Pinto::Difference->new(left => $left, right => $right);

    for my $entry ($diff->diffs) {
        my $op     = $entry->op;
        my $reg    = $entry->registration;
        my $color  = $op eq '+' ? $PINTO_COLOR_0 : $PINTO_COLOR_2;
        my $string = $op . $reg->to_string('[%F] %-40p %12v %a/%f');
        $self->show($string, {color => $color});
    }

    return $self->result;
}

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Action::Diff - Show the difference between two stacks

=head1 VERSION

version 0.080

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

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
