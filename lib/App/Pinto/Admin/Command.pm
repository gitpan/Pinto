package App::Pinto::Admin::Command;

# ABSTRACT: Base class for pinto-admin commands

use strict;
use warnings;

use Pod::Usage qw(pod2usage);

#-----------------------------------------------------------------------------

use App::Cmd::Setup -command;

#-----------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#-----------------------------------------------------------------------------

sub opt_spec {
    my ( $self, $app ) = @_;

    return (

        [ 'man' => 'Show manual for this command' ],
    );
}

#-----------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    return '%c --repos=PATH $command [OPTIONS] [ARGS]'
}

#-----------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->show_manual_and_exit() if $opts->{man};

    return 1;
}

#-----------------------------------------------------------------------------


sub pinto {
    my ($self) = @_;
    return $self->app->pinto();
}

#-----------------------------------------------------------------------------

sub show_manual_and_exit {
    my ($self) = @_;
    my $class = ref $self;
    (my $relative_path = $class) =~ s< :: ></>xmsg;
    $relative_path .= '.pm';

    my $absolute_path = $INC{$relative_path}
      or die "No manual available for $class";  ## no critic qw(Carping)

    pod2usage(-verbose => 2, -input => $absolute_path, -exitval => 0);
}

#-----------------------------------------------------------------------------


1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command - Base class for pinto-admin commands

=head1 VERSION

version 0.021

=head1 METHODS

=head2 pinto()

Returns the Pinto object for this command.  Basically an alias for

  $self->app();

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
