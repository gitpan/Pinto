package App::Pinto::Command::remove;

# ABSTRACT: remove your own packages from the repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.002'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    return (
        [ "author=s"  => 'Your PAUSE ID' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;
    my ($command) = $self->command_names();
    return "%c [global options] $command [command options] PACKAGE [PACKAGE...]";
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("Must specify one or more package arguments") unless @{ $args };
}

#------------------------------------------------------------------------------

sub execute {
    $DB::single = 1;
    my ($self, $opts, $args) = @_;
    $self->pinto()->remove(author => $opts->{author}, package => $_) for @{ $args };
    $self->pinto()->clean() unless $self->pinto()->config()->get('nocleanup');
    return 0;
}

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Command::remove - remove your own packages from the repository

=head1 VERSION

version 0.002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
