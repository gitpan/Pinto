# ABSTRACT: Something that has chrome plating

package Pinto::Role::Plated;

use Moose::Role;
use MooseX::MarkAsMethods (autoclean => 1);

#-----------------------------------------------------------------------------

our $VERSION = '0.082'; # VERSION

#-----------------------------------------------------------------------------

has chrome => (
    is         => 'ro',
    isa        => 'Pinto::Chrome',
    handles    => [ qw(show info notice warning error) ],
    required   => 1,
);

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Role::Plated - Something that has chrome plating

=head1 VERSION

version 0.082

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
