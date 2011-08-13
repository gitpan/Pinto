package Pinto::Logger;

# ABSTRACT: A simple logger

use Moose;
use MooseX::Types::Moose qw(Int);

use Readonly;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.009'; # VERSION

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

Readonly my $LOG_LEVEL_QUIET => -2;
Readonly my $LOG_LEVEL_WARN  => -1;
Readonly my $LOG_LEVEL_INFO  =>  0;
Readonly my $LOG_LEVEL_DEBUG =>  1;

#-----------------------------------------------------------------------------
# Builders

sub _build_log_level {
    my ($self) = @_;

    return $LOG_LEVEL_QUIET if $self->config->quiet();
    return $self->config->verbose();
}

#-----------------------------------------------------------------------------
# Private functions

sub _logit {
    my ($message) = @_;

    return print "$message\n";
}

#-----------------------------------------------------------------------------
# Public methods

sub debug {
    my ($self, $message) = @_;

    _logit($message) if $self->log_level() >= $LOG_LEVEL_DEBUG;

    return 1;
}

#-----------------------------------------------------------------------------

sub info {
    my ($self, $message) = @_;

    _logit($message) if $self->log_level() >= $LOG_LEVEL_INFO;

    return 1;
}

#-----------------------------------------------------------------------------

sub whine {
    my ($self, $message) = @_;

    warn "$message\n" if $self->log_level() >= $LOG_LEVEL_WARN;

    return 1;
}

#-----------------------------------------------------------------------------

sub fatal {
    my ($self, $message) = @_;

    die "$message\n";  ## no critic (RequireCarping)
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

version 0.009

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
