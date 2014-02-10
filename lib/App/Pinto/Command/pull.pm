# ABSTRACT: pull archives from upstream repositories

package App::Pinto::Command::pull;

use strict;
use warnings;

#------------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.0992'; # VERSION

#-----------------------------------------------------------------------------

sub opt_spec {
    my ( $self, $app ) = @_;

    return (
        [ 'cascade'                           => 'Always pick latest upstream package' ],
        [ 'diff-style=s'                      => 'Set style of diff reports' ],
        [ 'dry-run'                           => 'Do not commit any changes' ],
        [ 'message|m=s'                       => 'Message to describe the change' ],
        [ 'no-fail'                           => 'Do not fail when there is an error' ],
        [ 'recurse!'                          => 'Recursively pull prereqs (negatable)' ],
        [ 'pin'                               => 'Pin the packages to the stack' ],
        [ 'skip-missing-prerequisite|k=s@'    => 'Skip missing prereq (repeatable)' ],
        [ 'skip-all-missing-prerequisites|K'  => 'Skip all missing prereqs' ],
        [ 'stack|s=s'                         => 'Put packages into this stack' ],
        [ 'use-default-message|M'             => 'Use the generated message' ],
        [ 'with-development-prerequisites|wd' => 'Also pull prereqs for development' ],
    );
}

#------------------------------------------------------------------------------

sub args_attribute { return 'targets' }

#------------------------------------------------------------------------------

sub args_from_stdin { return 1 }

#------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer norecurse

=head1 NAME

App::Pinto::Command::pull - pull archives from upstream repositories

=head1 VERSION

version 0.0992

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT pull [OPTIONS] TARGET ...

=head1 DESCRIPTION

This command locates packages in your upstream repositories and then pulls the
distributions providing those packages into your repository and registers them
on a stack.  Then it recursively locates and pulls  all the distributions that
are necessary to satisfy their prerequisites.   You can also request to
directly pull particular distributions.

When locating packages, Pinto first looks at the packages that already  exist
in the local repository, then Pinto looks at the packages that are available
on the upstream repositories.

=head1 COMMAND ARGUMENTS

Arguments are the targets that you want to pull.  Targets can be specified as
packages (with or without a version specification) or as distributions.
Targets can be expressed in a number of ways, so please see L</TARGETS> below
for more information.

You can also pipe arguments to this command over STDIN.  In that case, blank
lines and lines that look like comments (i.e. starting with "#" or ';') will
be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --cascade

!! THIS OPTION IS EXPERIMENTAL !!

When searching for a package (or one of its prerequisites), always take
the latest satisfactory version of the package found amongst B<all> the
upstream repositories, rather than just taking the B<first> satisfactory
version that is found.  Remember that Pinto only searches the upstream
repositories when the local repository does not already contain a
satisfactory version of the package.

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

=item --no-fail

!! THIS OPTION IS EXPERIMENTAL !!

Normally, failure to pull a target (or its prerequisites) causes the
command to immediately abort and rollback the changes to the repository.
But if C<--no-fail> is set, then only the changes caused by the failed
target (and its prerequisites) will be rolled back and the command
will continue processing the remaining targets.

This option is useful if you want to throw a list of targets into
a repository and see which ones are problematic.  Once you've fixed
the broken ones, you can throw the whole list at the repository
again.

=item --message=TEXT

=item -m TEXT

Use TEXT as the revision history log message.  If you do not use the
C<--message> option or the C<--use-default-message> option, then you
will be prompted to enter the message via your text editor.  Use the
C<EDITOR> or C<VISUAL> environment variables to control which editor
is used.  A log message is not required whenever the C<--dry-run>
option is set, or if the action did not yield any changes to the
repository.

=item --pin

Pins the packages to the stack, so they cannot be changed until you unpin
them.  Only the packages in the requested targets will be pinned -- packages
in prerequisites will not be pinned.  However, you may pin them separately
with the L<pin|App::Pinto::Command::pin> command if you so desire.

=item --recurse

=item --no-recurse

Recursively pull any distributions required to satisfy prerequisites
for the targets.  The default value for this option can be configured
in the F<pinto.ini> configuration file for the repository (it is usually
set to 1).  To disable recursion, use C<--no-recurse>.

=item --skip-missing-prerequisite=PACKAGE

=item -k PACKAGE

!! THIS OPTION IS EXPERIMENTAL !!

Skip any prerequisite with name PACKAGE if a satisfactory version cannot be
found.  However, a warning will be given whenever this occurrs.  This option only
has effect when recursively fetching prerequisites for the targets (See also
the C<--recurse> option). This option can be repeated.

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

=head1 TARGETS

Targets are a compact notation that identifies the things you want to pull
into your repository.  Targets come in two flavors: package targets and
distribution targets.

=head2 Package Targets

A package target consists of a package name and (optionally) a version
specification.  Here are some examples:

  Foo::Bar                                 # Any version of Foo::Bar
  Foo::Bar~1.2                             # Foo::Bar version 1.2 or higher
  Foo::Bar==1.2                            # Only version 1.2 of Foo::Bar
  Foo::Bar<1,2!=1.3,<=1.9                  # Complex version range

Package names are case-sensitive, and the version specification must follow
the format used by L<CPAN::Meta::Requirements>.  All whitespace within the
target will be discarded.  If your version specification contains any special
shell characters, take care to quote or escape them in your command.

In all cases, pinto queries the local repository and then each upstream
repository in order, and pulls the first distribution it can find that
provides a package which satisfies the version specification.

=head2 Distribution Targets

A distribution target consists of an author ID, zero or more subdirectories,
and the distribution name and version number.   This corresponds to the actual
path where the distribution archive lives in the repository or CPAN mirror.
Here are some examples.

  SHAKESPEARE/King-Lear-1.2.tar.gz         # A specific distribution
  SHAKESPEARE/tragedies/Hamlet-4.2.tar.gz  # Same, but with a subdirectory

The author ID will always be forced to uppercase, but the reset of the path is
case-sensitive.

=head2 Caveats

L<PAUSE|http://pause.perl.org> has no strict rules on how packages are
versioned.  It is quite common to see a package with the same verison number
(or no version at all) in many releases of a distribution.  So when you
specify a package target with a precise version or version range, what you
actually get is the latest distribution (chronologically) that has a package
which satisfies the target.  Most of the time this works out fine because you
usally pull the "main module" of the distribution and authors always increment
that version in each release.

Since most CPAN mirrors only report the latest version of a package they have,
they often cannot satisfy package targets that have a precise version
specification.  However, the mirror at L<http://cpan.stratopan.com> is special
and can locate a precise version of any package.

Package targets always resolve to production releases, unless you specify a
precise developer release version (e.g. C<Foo::Bar==1.03_01>).  But since most
CPAN mirrors do not index developer releases, this only works when using the
mirror at L<http://cpan.stratopan.com>.  However, you can usually pull a
developer release from any mirror by using a distribution target.  Remember
that developer releases are those with an underscore in the version number.

For repositories created with Pinto version 0.098 or later, the first upstream
source is C<http://cpan.stratopan.com> (unless you configure it otherwise).
For repositories created with older versions, you can manually add
C<http://cpan.stratopan.com> to the C<sources> parameter in the configuration
file located at F<.pinto/config/pinto.ini> within the repository.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
