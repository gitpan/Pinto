# ABSTRACT: create a new empty stack

package App::Pinto::Command::new;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.084'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'default'               => 'Make the new stack the default stack' ],
        [ 'description|d=s'       => 'Brief description of the stack'       ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Must specify exactly one stack')
        if @{$args} != 1;

    $opts->{stack} = $args->[0];

    return 1;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::new - create a new empty stack

=head1 VERSION

version 0.084

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT new [OPTIONS] STACK

=head1 DESCRIPTION

This command creates a new empty stack.

See the L<copy|App::Pinto::Command::copy> command to create a new 
stack from another one, or the L<props|App::Pinto::Command::props> 
command to change a stack's properties after it has been created.

=head1 COMMAND ARGUMENTS

The required argument is the name of the stack you wish to create.
Stack names must be alphanumeric plus hyphens and underscores, and
are not case sensitive.

=head1 COMMAND OPTIONS

=over 4

=item --default

Also mark the new stack as the default stack.

=item --description=TEXT

=item -d TEXT

Use TEXT for the description of the stack.

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
