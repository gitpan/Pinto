package App::Pinto::Admin::Command::mirror;

# ABSTRACT: get all the latest distributions from a remote repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.017'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    return (
        [ 'force' => 'Force action, even if indexes appear unchanged' ],
        [ 'message=s' => 'Prepend a message to the VCS log'],
        [ 'nocommit'  => 'Do not commit changes to VCS'],
# TODO       [ 'notag'     => 'Do not create any tag in VCS'],
# TODO       [ 'tag=s'     => 'Specify an alternate tag name' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;
    $self->usage_error('Arguments are not allowed') if @{ $args };
    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    $self->pinto->new_action_batch( %{$opts} );
    $self->pinto->add_action('Mirror', %{$opts});
    my $result = $self->pinto->run_actions();
    return $result->is_success() ? 0 : 1;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::mirror - get all the latest distributions from a remote repository

=head1 VERSION

version 0.017

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
