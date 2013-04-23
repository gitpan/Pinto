# ABSTRACT: Base class for responders

package Pinto::Server::Responder;

use Moose;

use Carp;

use Pinto::Types qw(Dir);

#-------------------------------------------------------------------------------

our $VERSION = '0.079_04'; # VERSION

#-------------------------------------------------------------------------------

has request => (
    is       => 'ro',
    isa      => 'Plack::Request',
    required => 1,
);


has root => (
    is       => 'ro',
    isa      => Dir,
    required => 1,
);

#-------------------------------------------------------------------------------


sub respond { croak 'abstract method' }

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer responders

=head1 NAME

Pinto::Server::Responder - Base class for responders

=head1 VERSION

version 0.079_04

=head1 METHODS

=head2 respond( $request )

Given a L<Plack::Request>, responds with the appropriate
PSGI-compatible response.  This is an abstract method.  It is your job
to implement it in a concrete subclass.

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
