package Pinto::ActionBatch;

# ABSTRACT: Runs a series of actions

use Moose;
use Moose::Autobox;

use Pinto::IndexManager;

#-----------------------------------------------------------------------------

our $VERSION = '0.014'; # VERSION

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

#-----------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Role::Loggable
         Pinto::Role::Configurable );

#-----------------------------------------------------------------------------


sub enqueue {
    my ($self, @actions) = @_;

    $self->actions()->push( @actions );

    return $self;
}

#-----------------------------------------------------------------------------
# TODO: Trap exceptions here...


sub run {
    my ($self) = @_;

    $self->store->initialize()
        unless $self->store->is_initialized()
           and $self->config->noinit();


    my @messages;
    my $changes_were_made;
    while ( my $action = $self->actions->shift() ) {
        # TODO: Trap exceptions here?
        $changes_were_made += $action->execute();
        push @messages, $action->messages->flatten();
    }


    $self->logger->info('No changes were made') and return $self
      unless $changes_were_made;


    $self->idxmgr->write_indexes();
    # Always put the modules directory on the commit list!
    my $modules_dir = $self->config->local->subdir('modules');
    $self->store->modified_paths->push( $modules_dir );

    return $self if $self->config->nocommit();

    my $batch_message  = join "\n\n", @messages;
    $self->logger->debug($batch_message);
    $self->store->finalize(message => $batch_message);

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

version 0.014

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
