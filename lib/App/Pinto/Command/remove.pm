package App::Pinto::Command::remove;

# ABSTRACT: remove your own packages from the repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.006'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    return (
        [ "author=s"  => 'Your author ID (like a PAUSE ID)' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;
    my ($command) = $self->command_names();
    return "%c [global options] $command [command options] PACKAGE";
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;
    $self->usage_error("Must specify exactly one package") if @{ $args } != 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;
    $self->pinto( $opts )->remove( package => $args->[0] );
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Command::remove - remove your own packages from the repository

=head1 VERSION

version 0.006

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
