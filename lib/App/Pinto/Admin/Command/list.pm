package App::Pinto::Admin::Command::list;

# ABSTRACT: list the contents of the repository

use strict;
use warnings;

use Readonly;
use List::MoreUtils qw(none);

use Pinto::Constants qw(:list);

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.023'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    # TODO: Use the "one_of" feature of Getopt::Long::Descriptive to
    # define and validate the different types of lists.

    return ( $self->SUPER::opt_spec(),

        [ 'noinit'  => 'Do not pull/update from VCS' ],
        [ 'type:s'  => "One of: ( $PINTO_LIST_TYPES_STRING )" ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->SUPER::validate_args($opts, $args);

    $self->usage_error('Arguments are not allowed') if @{ $args };

    $opts->{type} ||= $PINTO_DEFAULT_LIST_TYPE;
    $self->usage_error('Invalid type') if none { $opts->{type} eq $_ } @PINTO_LIST_TYPES;

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    $self->pinto->new_action_batch( %{$opts} );
    my $list_class = 'List::' . ucfirst $opts->{type};
    $self->pinto->add_action($list_class, %{$opts});
    my $result = $self->pinto->run_actions();
    return $result->is_success() ? 0 : 1;

}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::list - list the contents of the repository

=head1 VERSION

version 0.023

=head1 SYNOPSIS

  pinto-admin --path=/some/dir list [OPTIONS]

=head1 DESCRIPTION

This command lists the distributions and packages that are indexed in
your repository.  You can see all of them, only foreign ones, only
local ones, or only the local ones that conflict with a foreign one.

Note this command never changes the state of your repository.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

=over 4

=item --noinit

Prevents L<Pinto> from pulling/updating the repository from the VCS
before the operation.  This is only relevant if you are using a
VCS-based storage mechanism.  This can speed up operations
considerably, but should only be used if you *know* that your working
copy is up-to-date and you are going to be the only actor touching the
Pinto repository within the VCS.

=item --type=(all | local | foreign | conflicts)

Specifies what type of packages and distributions to list. In all
cases, only packages and distributions that are indexed will appear.
If you have outdated distributions in your repository, they will never
appear here.  Valid types are:

=over 8

=item all

Lists all the packages and distributions.

=item local

Lists only the local packages and distributions that were added with
the C<add> command.

=item foreign

Lists only the foreign packages and distributions that were pulled in
with the C<update> command.

=item conflicts

Lists only the local distributions that conflict with a foreign
distribution.  In other words, the local and foreign distribution
contain a package with the same name.

=back

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

