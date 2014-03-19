# ABSTRACT: update packages to latest versions

package App::Pinto::Command::update;

use strict;
use warnings;

#------------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.0995'; # VERSION

#-----------------------------------------------------------------------------

sub opt_spec {
    my ( $self, $app ) = @_;

    return (
        [ 'all'                               => 'Update all packages in the stack' ],
        [ 'cascade'                           => 'Always pick latest upstream package' ],
        [ 'diff-style=s'                      => 'Set style of diff reports' ],
        [ 'dry-run'                           => 'Do not commit any changes' ],
        [ 'force'                             => 'Force update, even if pinned' ],
        [ 'message|m=s'                       => 'Message to describe the change' ],
        [ 'no-fail'                           => 'Do not fail when there is an error' ],
        [ 'recurse!'                          => 'Recursively pull prereqs (negatable)' ],
        [ 'pin'                               => 'Pin the packages to the stack' ],
        [ 'roots'                             => 'Update all root packages in the stack' ],
        [ 'skip-missing-prerequisite|k=s@'    => 'Skip missing prereq (repeatable)' ],
        [ 'skip-all-missing-prerequisites|K'  => 'Skip all missing prereqs' ],
        [ 'stack|s=s'                         => 'Update packages in this stack' ],
        [ 'use-default-message|M'             => 'Use the generated message' ],
        [ 'with-development-prerequisites|wd' => 'Also pull prereqs for development' ],
    );
}

#------------------------------------------------------------------------------

sub args_attribute { return 'targets' }

#------------------------------------------------------------------------------

sub args_from_stdin { return not ($_[1]->{all} || $_[1]->{roots}) }

#------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux brian d foy hesco popl Däppen Cory
G Watson David Steinbrunner Glenn norecurse

=head1 NAME

App::Pinto::Command::update - update packages to latest versions

=head1 VERSION

version 0.0995

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT update [OPTIONS] TARGET ...

=head1 DESCRIPTION

!! THIS COMMAND IS EXPERIMENTAL !!!

This command updates packages in your repository to the newer versions in an
updstream repository.  By default, Pinto takes the first newer version that it
finds.  If the C<--cascade> option is used, then Pinto will take the newest
version it finds among all the upstream repositories.

=head1 COMMAND ARGUMENTS

Arguments are the names of the pakcages you want to install.  If using the
C<--all> or C<--roots> options then arguments are not allowed.

You can also pipe arguments to this command over STDIN.  In that case, blank
lines and lines that look like comments (i.e. starting with "#" or ';') will
be ignored.  If using the C<--all> or C<--roots> options, then input will not
be read from STDIN.

=head1 COMMAND OPTIONS

=over 4

=item --all

Update all distributions in the stack.  We do not attempt to update locally
added distributions unless C<--force> is used.  If this option is used, then
package names cannot be given as command arguments.  See also the C<--roots>
option.

=item --cascade

!! THIS OPTION IS EXPERIMENTAL !!

When searching for a package (or one of its prerequisites), always take the
latest satisfactory version of the package found amongst B<all> the upstream
repositories, rather than just taking the B<first> newer version that
is found.  Remember that Pinto only searches the upstream repositories when
the local repository does not already contain a satisfactory version of the
package.

=item --diff-style=STYLE

Controls the style of the diff reports.  STYLE must be either C<concise> or
C<detailed>.  Concise reports show only one record for each distribution added
or deleted.  Detailed reports show one record for every package added or
deleted.

The default style is C<concise>.  However, the default style can changed by
setting the C<PINTO_DIFF_STYLE> environment variable to your preferred STYLE.
This variable affects the default style for diff reports generated by all
other commands too.

=item --dry-run

Go through all the motions, but do not actually commit any changes to the
repository.  At the conclusion, a diff showing the changes that would have
been made will be displayed.  Use this option to see how upgrades would
potentially impact the stack.

=item --force

Forcibly unpin any packages that require updating.  The pins will not be
restored after a succesful update.

=item --no-fail

!! THIS OPTION IS EXPERIMENTAL !!

Normally, failure to pull a target (or its prerequisites) causes the command
to immediately abort and rollback the changes to the repository. But if C
<--no-fail> is set, then only the changes caused by the failed target (and its
prerequisites) will be rolled back and the command will continue processing
the remaining targets.

This option is useful if you want to throw a list of targets into a repository
and see which ones are problematic.  Once you've fixed the broken ones, you
can throw the whole list at the repository again.

=item --message=TEXT

=item -m TEXT

Use TEXT as the revision history log message.  If you do not use the
C<--message> option or the C<--use-default-message> option, then you will be
prompted to enter the message via your text editor.  Use the C<PINTO_EDITOR>
or C<EDITOR> or C<VISUAL> environment variables to control which editor is
used.  A log message is not required whenever the C<--dry-run> option is set,
or if the action did not yield any changes to the repository.

=item --pin

Pins the packages to the stack, so they cannot be changed until you unpin
them.  Only the packages in the requested targets will be pinned -- packages
in prerequisites will not be pinned.  However, you may pin them separately
with the L<pin|App::Pinto::Command::pin> command if you so desire.

=item --recurse

=item --no-recurse

Recursively pull any distributions required to satisfy prerequisites for the
targets.  The default value for this option can be configured in the
F<pinto.ini> configuration file for the repository (it is usually set to 1).
To disable recursion, use C<--no-recurse>.

=item --roots

Updates the root distributions of the stack.  We do not attempt to update
locally added distributions unless C<--force> is used.  If this option is
used, then package names cannot be given as command arguments.  See also the
C<--all> option.

=item --skip-missing-prerequisite=PACKAGE

=item -k PACKAGE

!! THIS OPTION IS EXPERIMENTAL !!

Skip any prerequisite with name PACKAGE if a satisfactory version cannot be
found.  However, a warning will be given whenever this occurrs.  This option
only has effect when recursively fetching prerequisites for the targets (See
also the C<--recurse> option). This option can be repeated.

=item --skip-all-missing-prerequisites

=item -K

!! THIS OPTION IS EXPERIMENTAL !!

Skips all missing prerequisites if a satisfactory version cannot be found.
However, a warning will be given whenever this occurrs.  This option will
silently override the C<--skip-missing-prerequisite> option and only has
effect when recursively fetching prerequisites for the targets (See also the
C<--recurse> option).

=item --stack=NAME

=item -s NAME

Puts all the packages onto the stack with the given NAME.  Defaults to the
name of whichever stack is currently marked as the default stack.  Use the
L<stacks|App::Pinto::Command::stacks> command to see the stacks in the
repository.

=item --use-default-message

=item -M

Use the default value for the revision history log message.  Pinto will
generate a semi-informative log message just based on the command and its
arguments.  If you set an explicit message with C<--message>, the C<--use-
default-message> option will be silently ignored.

=item --with-development-prerequisites

=item --wd

Also pull development prerequisites so you'll have everything you need
to work on those distributions, in the event that you need to patch them
in the future.  Be aware that most distributions do not actually declare
their development prerequisites.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
