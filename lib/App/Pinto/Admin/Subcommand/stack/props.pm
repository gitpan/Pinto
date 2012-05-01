# ABSTRACT: show stack properties

package App::Pinto::Admin::Subcommand::stack::props;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Subcommand';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {

  return (
      [ 'format=s' => 'Format specification (See POD for details)' ],
  );
}

#------------------------------------------------------------------------------


sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Cannot specify multiple stacks')
        if @{$args} > 1;

    $opts->{format} = eval qq{"$opts->{format}"} ## no critic qw(StringyEval)
        if $opts->{format};

    return 1;
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --root=PATH stack $command [OPTIONS] [STACK]
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my $stack = $args->[0];
    my $result = $self->pinto->run($self->action_name, %{$opts},
                                                       stack => $stack);

    return $result->exit_status;
}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Subcommand::stack::props - show stack properties

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir stack props [OPTIONS] STACK

=head1 DESCRIPTION

This command shows the properties of a stack.  See the C<stack edit>
subcommand to change the properties.

=head1 SUBCOMMAND ARGUMENTS

The argument is the name of the stack you wish to see the properties
for.  If you do not specify a stack, it defaults to whichever stack is
marked as the master.  Stack names must be alphanumeric (including "-"
or "_") and will be forced to lowercase.

=head1 SUBCOMMAND OPTIONS

=over 4

=item --format=FORMAT_SPECIFICATION

Format the output using C<printf>-style placeholders.  Valid
placeholders are:

  Placeholder    Meaning
  -----------------------------------------------------------------------------
  %n             Property name
  %v             Package value

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


