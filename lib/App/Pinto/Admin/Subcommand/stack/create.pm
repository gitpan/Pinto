# ABSTRACT: create a new empty stack

package App::Pinto::Admin::Subcommand::stack::create;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Subcommand';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

sub command_names { qw(create new) }

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

    $self->usage_error('Must specify exactly one stack')
        if @{$args} != 1;

    return 1;
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --root=PATH stack $command [OPTIONS] STACK
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my $result = $self->pinto->run($self->action_name, %{$opts},
                                                       stack => $args->[0]);

    return $result->exit_status;
}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Subcommand::stack::create - create a new empty stack

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir stack create [OPTIONS] STACK

=head1 DESCRIPTION

This command creates a new empty stack.

Please see the C<stack copy> subcommand to create a new stack from
another one, or the C<stack edit> subcommand to change a stack's
properties after it has been created.

=head1 SUBCOMMAND ARGUMENTS

The required argument is the name of the stack you wish to create.
Stack names must be alphanumeric (including "-" or "_") and will be
forced to lowercase.

=head1 SUBCOMMAND OPTIONS

=over 4

=item --description=TEXT

Annotates this stack with a description of its purpose.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


