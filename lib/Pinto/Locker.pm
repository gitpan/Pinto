# ABSTRACT: Manage locks to synchronize concurrent operations

package Pinto::Locker;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods ( autoclean => 1 );

use Path::Class;
use File::NFSLock;

use Pinto::Util qw(debug throw);
use Pinto::Types qw(File);

#-----------------------------------------------------------------------------

our $VERSION = '0.09996'; # VERSION

#-----------------------------------------------------------------------------

our $LOCKFILE_TIMEOUT = $ENV{PINTO_LOCKFILE_TIMEOUT} || 50;    # Seconds

#-----------------------------------------------------------------------------

has repo => (
    is       => 'ro',
    isa      => 'Pinto::Repository',
    weak_ref => 1,
    required => 1,
);

has _lock => (
    is        => 'rw',
    isa       => 'File::NFSLock',
    predicate => '_is_locked',
    clearer   => '_clear_lock',
    init_arg  => undef,
);

#-----------------------------------------------------------------------------


sub lock {    ## no critic qw(Homonym)
    my ( $self, $lock_type ) = @_;

    return if $self->_is_locked;

    $lock_type ||= 'SH';

    local $File::NFSLock::LOCK_EXTENSION = '';
    local @File::NFSLock::CATCH_SIGS     = ();

    my $root_dir  = $self->repo->config->root_dir;
    my $lock_file = $root_dir->file('.lock')->stringify;
    my $lock      = File::NFSLock->new( $lock_file, $lock_type, $LOCKFILE_TIMEOUT )
        or throw 'The repository is currently in use -- please try again later';

    debug("Process $$ got $lock_type lock on $root_dir");

    $self->_lock($lock);

    return $self;
}

#-----------------------------------------------------------------------------


sub unlock {
    my ($self) = @_;

    return $self if not $self->_is_locked;

    # I'm not sure if failure to unlock is really a problem
    $self->_lock->unlock or warn 'Unable to unlock repository';

    $self->_clear_lock;

    my $root_dir = $self->repo->config->root_dir;
    debug("Process $$ released the lock on $root_dir");

    return $self;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer NFS

=head1 NAME

Pinto::Locker - Manage locks to synchronize concurrent operations

=head1 VERSION

version 0.09996

=head1 DESCRIPTION

=head1 METHODS

=head2 lock

Attempts to get a lock on a Pinto repository.  If the repository is already
locked, we will attempt to contact the current lock holder and make sure they
are really alive.  If not, then we will steal the lock.  If they are, then
we patiently wait until we timeout, which is about 60 seconds.

=head2 unlock

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

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
