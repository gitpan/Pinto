# ABSTRACT: The result from running a remote Action

package Pinto::Remote::Result;

use Moose;

use MooseX::Types::Moose qw(Bool);

#-----------------------------------------------------------------------------

our $VERSION = '0.083'; # VERSION

#------------------------------------------------------------------------------

has was_successful => (
    is         => 'ro',
    isa        => Bool,
    default    => 0,
);

#-----------------------------------------------------------------------------


sub exit_status {
    my ($self) = @_;
    return $self->was_successful ? 0 : 1;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Remote::Result - The result from running a remote Action

=head1 VERSION

version 0.083

=head1 METHODS

=head2 exit_status()

Returns 0 if this result was successful.  Otherwise, returns 1.

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
