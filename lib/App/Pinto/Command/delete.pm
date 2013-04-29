# ABSTRACT: permanently remove an archive

package App::Pinto::Command::delete;

use strict;
use warnings;

#------------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.082'; # VERSION

#-----------------------------------------------------------------------------

sub command_names { return qw(delete remove del rm) }

#-----------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'force'  => 'Delete even if packages are pinned'  ],
    );
}

#------------------------------------------------------------------------------

sub args_attribute { return 'targets'; }

#------------------------------------------------------------------------------

sub args_from_stdin { return 1; }

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::delete - permanently remove an archive

=head1 VERSION

version 0.082

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT deiete [OPTIONS] TARGET ...

=head1 DESCRIPTION

!! THIS COMMAND IS EXPERIMENTAL !!

B<IMPORTANT:>  This command is dangerous.  If you just want to remove
packages or distributions from a stack, then you should probably be looking 
at the L<unregister|App::Pinto::Command::unregister> command instead.

This command permanently removes an archive from the repository, thereby 
unregistering it from all stacks and wiping it from all history (as if 
it had never been put in the repository).  Beware that once an archive 
is deleted it cannot be recovered.  There will be no record that the
archive was ever added or deleted, and this change cannot be undone.

To merely remove packages from a stack (while preserving the archive),
use the L<unregister|App::Pinto::Command::unregister> command.

=head1 COMMAND ARGUMENTS

Arguments are the archives that you want to delete.  Archives are
specified as C<AUTHOR/ARCHIVE-NAME>.  For example:

  SHAKESPEARE/King-Lear-1.2.tar.gz

You can also pipe arguments to this command over STDIN.  In that case,
blank lines and lines that look like comments (i.e. starting with "#"
or ';') will be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --force

Deletes the archive even if its packages are pinned to a stack.  Take
care when deleting pinned packages, as it usually means that
particular package is important to someone.

=back

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
