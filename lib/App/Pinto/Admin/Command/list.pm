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

our $VERSION = '0.022'; # VERSION

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

version 0.022

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
