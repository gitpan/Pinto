package App::Pinto::Command::add;

# ABSTRACT: add your own Perl archives to the repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.006'; # VERSION

#-----------------------------------------------------------------------------

sub opt_spec {
    return (
        [ "author=s"  => 'Your author ID (like a PAUSE ID)' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;
    my ($command) = $self->command_names();
    return "%c [global options] $command [command options] ARCHIVE";
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;
    $self->usage_error("Must specify exactly one archive") if @{ $args } != 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;
    $self->pinto( $opts )->add( file => $args->[0] );
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Command::add - add your own Perl archives to the repository

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
