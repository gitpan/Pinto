#ABSTRACT: show difference between two stacks

package App::Pinto::Command::diff;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.081'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw(diff) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return ();
}

#------------------------------------------------------------------------------
sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Must specify at least one stack') if @{$args} < 1;

    $self->usage_error('Cannot specify more than two stacks') if @{$args} > 2;
    
    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    # If there's only one stack, then the
    # left stack is the default (i.e. undef)
    unshift @{$args}, undef if @{$args} == 1;

    my %stacks = ( left_stack => $args->[0], right_stack => $args->[1] );
    my $result = $self->pinto->run($self->action_name, %{$opts}, %stacks);

    return $result->exit_status;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::diff - show difference between two stacks

=head1 VERSION

version 0.081

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT diff [OPTIONS] [LEFT_STACK] RIGHT_STACK

=head1 DESCRIPTION

!! THIS COMMAND IS EXPERIMENTAL !!

This command shows the difference between two stacks, presented in a
format similar to diff[1].

=head1 COMMAND ARGUMENTS

Command arguments are the names of the stacks to compare.  If you only
specify one argument, then it is assumed to be the right stack and
whichever stack is currently marked as the default will be used as
the left stack.  All comparisons are made between the head revisions
of each stack.

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
