package App::Pinto::Admin::Subcommand::stack::list;

# ABSTRACT: show stacks (or their contents)

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Subcommand';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

sub command_names { qw(list ls) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'format=s' => 'Format of the listing' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --root=PATH stack $command [OPTIONS]
%c --root=PATH stack $command [OPTIONS] STACK
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Cannot specify multiple stacks')
        if @{ $args } > 1;

    $opts->{format} = eval qq{"$opts->{format}"} ## no critic qw(StringyEval)
        if $opts->{format};

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    # NOTE: If an argument is given, it means to list the stack
    # members, not the stacks themselves.  So we run the List action
    # instead of the usual Stack::List action.

    my $result;
    if ( my $stack = $args->[0] ) {
        my $where = { 'stack.name' => $stack };
        $result = $self->pinto->run('List', %{$opts}, where => $where);
    }
    else {
        $result = $self->pinto->run($self->action_name, %{$opts});
    }

    return $result->exit_status;
}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Subcommand::stack::list - show stacks (or their contents)

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir stack list [OPTIONS]
  pinto-admin --root=/some/dir stack list [OPTIONS] STACK_NAME

=head1 DESCRIPTION

This command lists the names (and some other details) of all the
stacks in the repository.  Or it will list the contents of a
particular stack.

=head1 SUBCOMMAND ARGUMENTS

If given no arguments, then just stack names and basic information are
shown.  If given a C<STACK> argument, then the contents of that stack
will be listed instead.  So the following two commands are equivalent:

$> pinto-admin --root=/some/dir list --stack=development
$> pinto-admin --root=/some/dir stack list development

=head1 SUBCOMMAND OPTIONS

=over 4

=item --format=FORMAT_SPECIFICATION

Format each record in the listing with C<printf>-style placeholders.
Valid placeholders are:

  Placeholder    Meaning
  -----------------------------------------------------------------------------
  %k             Stack name
  %e             Stack description
  %M             Stack status                                    (*) = master
  %U             Stack last-modified-on
  %j             Stack last-modified-by
  %%             A literal '%'

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

