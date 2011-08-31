package App::Pinto::Admin::Command::update;

# ABSTRACT: get all the latest distributions from another repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.022'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return ( $self->SUPER::opt_spec(),

        [ 'force'       => 'Force action, even if indexes appear unchanged' ],
        [ 'message|m=s' => 'Prepend a message to the VCS log' ],
        [ 'nocommit'    => 'Do not commit changes to VCS' ],
        [ 'noinit'      => 'Do not pull/update from VCS' ],
        [ 'tag=s'       => 'Specify a VCS tag name' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->SUPER::validate_args($opts, $args);

    $self->usage_error('Arguments are not allowed') if @{ $args };

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    $self->pinto->new_action_batch( %{$opts} );
    $self->pinto->add_action('Update', %{$opts});
    my $result = $self->pinto->run_actions();
    return $result->is_success() ? 0 : 1;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::update - get all the latest distributions from another repository

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
