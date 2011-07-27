package App::Pinto::Command::update;

# ABSTRACT: get the latest archives from a CPAN mirror

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.002'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    return (
        [ "remote=s"  => 'URL of a CPAN mirror' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("Arguments are not allowed") if @{ $args };
}

#------------------------------------------------------------------------------

sub execute {
    $DB::single = 1;
    my ($self, $opts, $args) = @_;
    $self->pinto()->update(remote => $opts->{remote});
    $self->pinto()->clean() unless $self->pinto()->config()->get('nocleanup');
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Command::update - get the latest archives from a CPAN mirror

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
