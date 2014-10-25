package Pinto::Locker;

# ABSTRACT: Synchronize concurrent Pinto actions

use Moose;

use Carp;
use Path::Class;
use LockFile::Simple;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.016'; # VERSION

#-----------------------------------------------------------------------------
# Moose attributes

has _lock => (
    is       => 'rw',
    isa      => 'LockFile::Lock',
    init_arg => undef,
);

#-----------------------------------------------------------------------------
# Moose roles

with qw ( Pinto::Role::Configurable
          Pinto::Role::Loggable );

#-----------------------------------------------------------------------------


sub lock {                                             ## no critic (Homonym)
    my ($self) = @_;

    my $local = $self->config->local();
    my $wfunc = sub { $self->logger->debug(@_) };
    my $efunc = sub { $self->logger->fatal(@_) };

    my $lockmgr = LockFile::Simple->make( -autoclean => 1,
                                          -efunc     => $efunc,
                                          -wfunc     => $wfunc,
                                          -stale     => 1,
                                          -nfs       => 1 );

    my $lock = $lockmgr->lock( $local . '/' )
        or croak 'Unable to lock the repository.  Please try later.';

    $self->logger->debug("Process $$ got the lock for $local");
    $self->_lock($lock);

    return $self;
}

#-----------------------------------------------------------------------------


sub unlock {
    my ($self) = @_;

    $self->_lock->release()
        or croak 'Unable to unlock the repository';

    return $self;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems NFS

=head1 NAME

Pinto::Locker - Synchronize concurrent Pinto actions

=head1 VERSION

version 0.016

=head1 DESCRIPTION

=head1 METHODS

=head2 lock()

Attempts to get a lock on the Pinto repository.  If the repository is already
locked, we will attempt to contact the current lock holder and make sure they
are really alive.  If not, then we will steal the lock.  If they are, then
we patiently wait until we timeout, which is about 60 seconds.

=head2 unlock()

Releases the lock on the Pinto repository so that other processes can
get to work.

In many situations, a Pinto repository is a shared resource.  At any
given moment, multiple processes may be trying to add distributions,
remove packages, or pull files from a mirror.  To keep things working
properly, we can only let one process fiddle with the repository at a
time.  This module manages a lock file for that purpose.

Supposedly, this does work on NFS.  But it cannot steal the lock from
a dead process if that process was not running on the same host.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

