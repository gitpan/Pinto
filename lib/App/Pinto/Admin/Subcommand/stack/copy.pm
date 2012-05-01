# ABSTRACT: create a new stack by copying another

package App::Pinto::Admin::Subcommand::stack::copy;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Subcommand';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

sub command_names { qw(copy cp) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'description|d=s' => 'Brief description of the stack' ],
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

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --root=PATH stack $command [OPTIONS] FROM_STACK TO_STACK
END_USAGE

    chomp $usage;
    return $usage;
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



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Subcommand::stack::copy - create a new stack by copying another

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir stack copy [OPTIONS] FROM_STACK TO_STACK

=head1 DESCRIPTION

This command creates a new stack by copying an existing one.  All the
pins and properties from the existing stack will also be copied to the
new one.  The new stack must not already exist.

Please see the C<stack create> subcommand to create a new empty stack, or
the C<stack edit> subcommand to change a stack's properties after it has
been created.

=head1 SUBCOMMAND ARGUMENTS

The two required arguments are the name of the source and target
stacks.  Stack names must be alphanumeric (including "-" or "_") and
will be forced to lowercase.

=head1 SUBCOMMAND OPTIONS

=over 4

=item --description=TEXT

Annotates the new stack with a brief description of its purpose.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

