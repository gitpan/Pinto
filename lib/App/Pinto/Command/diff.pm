#ABSTRACT: show difference between two stacks

package App::Pinto::Command::diff;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.093'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw(diff) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ( $self, $app ) = @_;

    return ();
}

#------------------------------------------------------------------------------
sub validate_args {
    my ( $self, $opts, $args ) = @_;

    $self->usage_error('Must specify at least one stack or revision') if @{$args} < 1;

    $self->usage_error('Cannot specify more than two stacks or revisions') if @{$args} > 2;

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ( $self, $opts, $args ) = @_;

    # If there's only one argument, then the left argument
    # is assumed to be the default stack (i.e. undef)
    unshift @{$args}, undef if @{$args} == 1;

    my %stacks = ( left => $args->[0], right => $args->[1] );
    my $result = $self->pinto->run( $self->action_name, %{$opts}, %stacks );

    return $result->exit_status;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux hesco popl Däppen Cory G Watson
David Steinbrunner Glenn

=head1 NAME

App::Pinto::Command::diff - show difference between two stacks

=head1 VERSION

version 0.093

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT diff [OPTIONS] [LEFT] RIGHT

=head1 DESCRIPTION

!! THIS COMMAND IS EXPERIMENTAL !!

This command shows the difference between two stacks or revisions, presented
in a format similar to diff[1].

=head1 COMMAND ARGUMENTS

Command arguments are the names of the stacks or revision IDs to compare. If
you specify a stack name, the head revision of that stack will be used.  If
you only specify one argument, then it is assumed to be the RIGHT and the head
revision of the default stack will be used as the LEFT.  Revision IDs can be
truncated to uniqueness.

=head1 COMMAND OPTIONS

None.

=head2 EXAMPLES

 pinto diff foo                  # Compare of head of default stack with head of foo stack
 pinto diff foo bar              # Compare heads of both foo and bar stack.
 pinto diff 1ae834f              # Compare head of default stack with revision 1ae834f
 pinto diff foo 1ae834f          # Compare head of foo stack with revision 1ae834f
 pinto diff 663fd2a 1ae834f      # Compare revision 663fd2a with revision 1ae834f

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
