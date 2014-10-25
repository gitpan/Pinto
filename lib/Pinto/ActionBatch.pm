package Pinto::ActionBatch;

# ABSTRACT: Runs a series of actions

use Moose;
use Moose::Autobox;

use Carp;
use Try::Tiny;
use Path::Class;

use Pinto::Locker;

#-----------------------------------------------------------------------------

our $VERSION = '0.016'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has 'store' => (
    is       => 'ro',
    isa      => 'Pinto::Store',
    required => 1
);

has actions => (
    is       => 'ro',
    isa      => 'ArrayRef[Pinto::Action]',
    default  => sub { [] },
);

has idxmgr => (
    is       => 'ro',
    isa      => 'Pinto::IndexManager',
    required => 1,
);

has message => (
    is       => 'ro',
    isa      => 'Str',
    writer   => '_set_message',
    default  => '',
);

has _locker  => (
    is       => 'ro',
    isa      => 'Pinto::Locker',
    builder  => '_build__locker',
    init_arg =>  undef,
    lazy     => 1,
);

#-----------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Role::Loggable
         Pinto::Role::Configurable );

#-----------------------------------------------------------------------------
# Builders

sub _build__locker {
    my ($self) = @_;

    return Pinto::Locker->new( config => $self->config(),
                               logger => $self->logger() );
}

#-----------------------------------------------------------------------------
# Public methods


sub enqueue {
    my ($self, @actions) = @_;

    $self->actions()->push( @actions );

    return $self;
}

#-----------------------------------------------------------------------------


sub run {
    my ($self) = @_;

    $self->_locker->lock();
    $self->_run_actions();
    $self->_locker->unlock();

    return $self;
}

#-----------------------------------------------------------------------------

sub _run_actions {
    my ($self) = @_;

    $self->store->initialize()
        unless $self->store->is_initialized()
           and $self->config->noinit();


    my $changes_were_made;
    while ( my $action = $self->actions->shift() ) {
        $changes_were_made += $self->_run_one_action($action);
    }

    $self->logger->info('No changes were made') and return $self
      unless $changes_were_made;

    $self->idxmgr->write_indexes();

    return $self if $self->config->nocommit();

    # Always put the modules directory on the commit list!
    my $modules_dir = $self->config->local->subdir('modules');
    $self->store->modified_paths->push( $modules_dir );

    my $batch_message = $self->message();
    $self->logger->debug($batch_message);
    $self->store->finalize(message => $batch_message);

    return $self;
}

#-----------------------------------------------------------------------------

sub _run_one_action {
    my ($self, $action) = @_;

    my $changes_were_made = 0;

    try {
        $changes_were_made += $action->execute();
        my @messages, $action->messages->flatten();
        $self->_append_messages(@messages);
    }
    catch {
        $self->logger->whine($_);
    };

    return $changes_were_made;
}


#-----------------------------------------------------------------------------

sub _append_messages {
    my ($self, @messages) = @_;

    my $current_message = $self->message();
    $current_message .= "\n\n" if $current_message;
    my $new_message = join "\n\n", @messages;
    $self->_set_message($new_message);

    return $self;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::ActionBatch - Runs a series of actions

=head1 VERSION

version 0.016

=head1 METHODS

=head2 enqueue($some_action)

Adds C<$some_action> to the end of the queue of L<Pinto::Action>s that will be
run.  Returns a reference to this C<ActionBatch>.

=head2 run()

Runs all the actions in this Batch.  Returns a reference to this C<ActionBatch>.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
