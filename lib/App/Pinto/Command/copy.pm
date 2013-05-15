# ABSTRACT: create a new stack by copying another

package App::Pinto::Command::copy;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.084'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw(copy cp) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'default'         => 'Make the new stack the default stack'  ],
        [ 'description|d=s' => 'Brief description of the stack'        ],
        [ 'lock'            => 'Lock the new stack to prevent changes' ],
    );


}

#------------------------------------------------------------------------------
sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Must specify FROM_STACK and TO_STACK')
        if @{$args} != 2;

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my %stacks = ( from_stack => $args->[0], to_stack => $args->[1] );
    my $result = $self->pinto->run($self->action_name, %{$opts}, %stacks);

    return $result->exit_status;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::copy - create a new stack by copying another

=head1 VERSION

version 0.084

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT copy [OPTIONS] FROM_STACK TO_STACK

=head1 DESCRIPTION

This command creates a new stack by copying an existing one.  All the
pins and properties from the existing stack will also be copied to the
new one.  The new stack must not already exist.

Use the L<new|App::Pinto::Command::new> command to create a new empty 
stack, or the L<props|App::Pinto::Command::props> command to change 
a stack's properties after it has been created.

=head1 COMMAND ARGUMENTS

The two required arguments are the name of the source and target
stacks.  Stack names must be alphanumeric plus hyphens and underscores,
and are not case-sensitive.

=head1 COMMAND OPTIONS

=over 4

=item --default

Also mark the new stack as the default stack.

=item --description=TEXT

=item -d TEXT

Use TEXT for the description of the stack.  If not specified, defaults
to 'Copy of stack FROM_STACK'.

=item --lock

Also lock the new stack to prevent future changes.  This is useful for
creating a read-only "tag" of a stack.  You can always use the
L<lock|App::Pinto::Command::lock> or
L<unlock|App::Pinto::Command::unlock> commands at a later time.

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

=item *

hesco <hesco@campaignfoundations.com>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
