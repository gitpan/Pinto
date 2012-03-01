package App::Pinto::Admin::Command;

# ABSTRACT: Base class for pinto-admin commands

use strict;
use warnings;

use Carp;

#-----------------------------------------------------------------------------

use App::Cmd::Setup -command;

#-----------------------------------------------------------------------------

our $VERSION = '0.032'; # VERSION

#-----------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    return '%c --root=PATH $command [OPTIONS] [ARGS]'
}

#-----------------------------------------------------------------------------

sub pinto {
    my ($self) = @_;
    return $self->app->pinto();
}

#-----------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    $self->pinto->new_batch( %{$opts} );
    $self->pinto->add_action( $self->action_name(), %{$opts} );
    my $result = $self->pinto->run_actions();

    return $result->is_success() ? 0 : 1;
}

#-----------------------------------------------------------------------------

sub action_name {
    my ($self) = @_;

    my $class = ref $self || $self;

    $class =~ m{ ([^:]+) $ }mx
      or croak "Unable to parse Action name from $class";

    return ucfirst $1;
}

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command - Base class for pinto-admin commands

=head1 VERSION

version 0.032

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
