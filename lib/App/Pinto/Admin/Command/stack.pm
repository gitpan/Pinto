# ABSTRACT: manage stacks within the repository

package App::Pinto::Admin::Command::stack;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::DispatchingCommand';

#-----------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub prepare_default_command {
    my ( $self, $opt, @args ) = @_;
    $self->_prepare_command( 'help' );
}

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::stack - manage stacks within the repository

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/path/to/repos [global options] stack SUBCOMMAND [subcommand options] [ARGS]

=head1 DESCRIPTION

The C<stack> command provides several subcommands for managing stacks.
Each stack is a subset of the packages within the repository.  Stacks
are used to manage the evolution of your dependencies.  You can "copy"
and "merge" stacks, much like a version control system.  Typical stack
names are things like "development" or "production" or "feature-xyz".

=head1 SUBCOMMANDS

The C<stack> command supports several subcommands that perform various
operations on your repository, or report information about your
repository.  To get a listing of all the available subcommands:

  $> pinto-admin stack commands

Each subcommand has its own options and arguments.  To get a brief
summary:

  $> pinto-admin stack help SUBCOMMAND

To see the complete manual for a subcommand:

  $> pinto-admin stack manual SUBCOMMAND

=head1 THE MASTER STACK

Many commands accept a stack name as an optional parameter.  In such
cases, if you do not specify an explicit stack name, it defaults to
whichever stack has been marked as the "master" stack.  The master
stack also governs which packages appear in the static index file for
your repository.

When you first create a repository, it has a stack named "default" and
it is marked as the master.  So initially, the default stack name for
all commands is "default".

Over time, you may create new stacks which you can view with the
C<stack list> command.  At some point, you may wish to select one of
them to become the new master stack, which you can do with the
C<stack edit> command.  Be sure to read and understand the caveats
about changing the master stack.

=head1 SEE ALSO

L<pinto-admin> for global options.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

