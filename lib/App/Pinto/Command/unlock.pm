# ABSTRACT: mark a stack as writable

package App::Pinto::Command::unlock;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.079_04'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'stack|s=s' => 'Unlock this stack' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Multiple arguments are not allowed')
        if @{ $args } > 1;

    $opts->{stack} = $args->[0]
        if $args->[0];

    return 1;
}

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::unlock - mark a stack as writable

=head1 VERSION

version 0.079_04

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT unlock [OPTIONS]

=head1 DESCRIPTION

This command unlocks a stack so that its packages can be changed.

Unlocking a stack does not cause an event in the revision history,
so reverting the stack will not restore the lock.  To lock a stack,
use the L<lock|App::Pinto::Command::lock> command.

=head1 COMMAND ARGUMENTS

As an alternative to the C<--stack> option, you can also specify the
stack as an argument. So the following examples are equivalent:

  pinto --root REPOSITORY_ROOT unlock --stack dev
  pinto --root REPOSITORY_ROOT unlock dev

A stack specified as an argument in this fashion will override any
stack specified with the C<--stack> option.

=head1 COMMAND OPTIONS

=over 4

=item --stack NAME

=item -s NAME

Unlock the stack with the given NAME.  Defaults to the name of whichever
stack is currently marked as the default stack.  Use the
L<stacks|App::Pinto::Command::stacks> command to see the stacks in the
repository.

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
