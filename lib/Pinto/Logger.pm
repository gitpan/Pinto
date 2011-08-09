package Pinto::Logger;

# ABSTRACT: A simple logger

use Moose;
use MooseX::Types::Moose qw(Int);

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.008'; # VERSION

#-----------------------------------------------------------------------------
# Moose attributes

has log_level => (
    is         => 'ro',
    isa        => Int,
    lazy_build => 1,
);


#-----------------------------------------------------------------------------
# Moose roles

with qw(Pinto::Role::Configurable);

#-----------------------------------------------------------------------------
# Builders

sub _build_log_level {
    my ($self) = @_;
    return -2 if $self->config->quiet();
    return $self->config->verbose();
}

#-----------------------------------------------------------------------------
# Private functions

sub _logit {
    my ($message) = @_;
    print "$message\n";
}

#-----------------------------------------------------------------------------
# Public methods

sub debug {
    my ($self, $message, $opts) = @_;
    _logit($message, $opts) if $self->log_level() >= 1;
}

#-----------------------------------------------------------------------------

sub log {
    my ($self, $message, $opts) = @_;
    _logit($message, $opts) if $self->log_level() >= 0;
}

#-----------------------------------------------------------------------------

sub warn {
    my ($self, $message) = @_;
    CORE::warn "$message\n" if $self->log_level() >= -1;
}

#-----------------------------------------------------------------------------

sub fatal {
    my ($self, $message) = @_;
    die "$message\n";
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Logger - A simple logger

=head1 VERSION

version 0.008

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
