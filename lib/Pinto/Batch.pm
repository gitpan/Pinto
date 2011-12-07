package Pinto::Batch;

# ABSTRACT: Runs a series of actions

use Moose;

use DateTime;
use Path::Class;
use Try::Tiny;

use Pinto::Result;

use Pinto::Types 0.017 qw(Dir);
use MooseX::Types::Moose qw(Str Bool);

#-----------------------------------------------------------------------------

our $VERSION = '0.026'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has repos    => (
    is       => 'ro',
    isa      => 'Pinto::Repository',
    required => 1
);


has messages => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    traits     => [ 'Array' ],
    handles    => {add_message => 'push'},
    default    => sub { [] },
    init_arg   => undef,
    auto_deref => 1,
);


has nocommit => (
    is       => 'ro',
    isa      => Bool,
    default  => 0,
);


has noinit   => (
    is       => 'ro',
    isa      => Bool,
    default  => sub { $_[0]->config->noinit() },
    lazy     => 1,
);


has tag => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_tag',
);

#-----------------------------------------------------------------------------

has actions => (
    is       => 'ro',
    isa      => 'ArrayRef[Pinto::Action]',
    traits   => [ 'Array' ],
    handles  => {enqueue => 'push', dequeue => 'shift'},
    init_arg => undef,
    default  => sub { [] },
);

#-----------------------------------------------------------------------------
# Private attributes


has _result => (
    is       => 'ro',
    isa      => 'Pinto::Result',
    default  => sub { Pinto::Result->new() },
    init_arg => undef,
);

#-----------------------------------------------------------------------------
# Roles

with qw( Pinto::Interface::Loggable
         Pinto::Interface::Configurable );

#-----------------------------------------------------------------------------
# Public methods


sub run {
    my ($self) = @_;

    $self->repos->initialize() unless $self->noinit();

    while ( my $action = $self->dequeue() ) {
        $self->_run_action($action);
    }

    if ( not  $self->_result->changes_made() ) {
        $self->note('No changes were made');
        return $self->_result();
    }

    $self->repos->write_index();

    $self->debug( $self->message_string() );

    return $self->_result() if $self->nocommit();

    $self->repos->commit( message => $self->message_string() );

    $self->repos->tag( tag => $self->tag() ) if $self->has_tag();

    return $self->_result();
}

#-----------------------------------------------------------------------------

sub message_string {
    my ($self) = @_;

    return join "\n\n", grep { length } $self->messages(), "\n";
}

#-----------------------------------------------------------------------------

sub _run_action {
    my ($self, $action) = @_;

    try   { $action->execute() && $self->_result->made_changes() }
    catch { $self->_handle_action_error( $_ ) };

    $self->add_message( $action->messages() );

    return $self;
}

#-----------------------------------------------------------------------------

sub _handle_action_error {
    my ($self, $error) = @_;

    if ( blessed($error) && $error->isa('Pinto::Exception') ) {
        $self->_result->add_exception($error);
        $self->whine($error);
        return $self;
    }

    $self->fatal($error);

    return $self;  # Should never get here
}


#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Batch - Runs a series of actions

=head1 VERSION

version 0.026

=head1 METHODS

=head2 run()

Runs all the actions in this Batch.  Returns a L<Pinto::Result>.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
