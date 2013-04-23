# ABSTRACT: change the name of a stack

package App::Pinto::Command::rename;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.079_04'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw(rename mv) }

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Must specify FROM_STACK and TO_STACK')
        if @{$args} != 2;

    $opts->{from_stack} = $args->[0];
    $opts->{to_stack}   = $args->[1];

    return 1;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::rename - change the name of a stack

=head1 VERSION

version 0.079_04

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT rename [OPTIONS] FROM_STACK TO_STACK

=head1 DESCRIPTION

This command changes the name of an existing stack.  Once the name is
changed, you will not be able to perform commands or access archives
via the old stack name.

See the L<new|App::Pinto::Command::new> command to create a new empty
stack, or the L<copy|App::Pinto::Command::copy> command to duplicate
an existing stack, or the L<props|App::Pinto::Command::props> command
to change a stack's properties after it has been created.

=head1 COMMAND ARGUMENTS

The two required arguments are the current name and new name of the
stack.  Stack names must be alphanumeric plus hyphens and underscores,
and are not case-sensitive.

=head1 COMMAND OPTIONS

NONE.

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