package App::Pinto::Admin::Command;

# ABSTRACT: Base class for pinto-admin commands

use strict;
use warnings;

use Carp;

#-----------------------------------------------------------------------------

use App::Cmd::Setup -command;

#-----------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    return "%c --root=PATH $command [OPTIONS] [ARGS]"
}

#-----------------------------------------------------------------------------

sub pinto {
    my ($self) = @_;
    return $self->app->pinto();
}

#-----------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error("Arguments are not allowed")
      if @{ $args } and not $self->args_attribute;

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my %args = $self->process_args($args);
    my $result = $self->pinto->run($self->action_name, %{$opts}, %args);

    return $result->exit_status;
}

#-----------------------------------------------------------------------------

sub process_args {
    my ($self, $args) = @_;

    my $attr = $self->args_attribute or return;

    if ( ! @{$args} && $self->args_from_stdin) {
        return ($attr => [ Pinto::Util::args_from_fh(\*STDIN) ]);
    }

    return ($attr => $args);
}

#-----------------------------------------------------------------------------

sub action_name {
    my ($self) = @_;

    my $class = ref $self || $self;  # why ref $self ??
    my $prefix = $self->command_namespace_prefix();

    $class =~ m/ ^ ${prefix}:: (.+) /mx
        or confess "Unable to parse Action name from $class";

    # Convert foo::bar::baz -> Foo::Bar:Baz
    # TODO: consider using a regex to do the conversion
    my $action_name = join '::', map {ucfirst} split '::', $1;

    return $action_name;
}

#-----------------------------------------------------------------------------

sub args_attribute { return '' }

#-----------------------------------------------------------------------------

sub args_from_stdin { return 0 }

#-----------------------------------------------------------------------------

sub command_namespace_prefix { return __PACKAGE__ }

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command - Base class for pinto-admin commands

=head1 VERSION

version 0.040_001

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
