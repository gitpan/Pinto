# ABSTRACT: remove orphaned distribution archives

package App::Pinto::Command::clean;

use strict;
use warnings;

#------------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.080'; # VERSION

#-----------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::clean - remove orphaned distribution archives

=head1 VERSION

version 0.080

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT clean

=head1 DESCRIPTION

The database for L<Pinto> is transactional, so failures and aborted
commands do not change the indexes.  However, the filesystem where
distribution archives are physically stored is not transactional and
may become cluttered with archives that are not in the database.

Normally, L<Pinto> tries to clean up those orphaned archives.  But in
some cases it might not.  Running this command will force their
removal.

This command also runs some optimizations on the database.  So if
your repository seems to be running slowly, try running this command
to see if performance improves.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

None.

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
