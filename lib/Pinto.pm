package Pinto;

# ABSTRACT: Perl distribution repository manager

use Moose;

use Class::Load;

use Pinto::Config;
use Pinto::Logger;
use Pinto::ActionBatch;
use Pinto::IndexManager;

use Pinto::Exception::Loader qw(throw_load);
use Pinto::Exception::Args qw(throw_args);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has _action_batch => (
    is         => 'ro',
    isa        => 'Pinto::ActionBatch',
    writer     => '_set_action_batch',
    init_arg   => undef,
);

#------------------------------------------------------------------------------

has _idxmgr => (
    is          => 'ro',
    isa         => 'Pinto::IndexManager',
    init_arg    => undef,
    lazy_build  => 1,
);

#------------------------------------------------------------------------------

has _store => (
    is         => 'ro',
    isa        => 'Pinto::Store',
    init_arg   => undef,
    lazy_build => 1,
);

#------------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Construction

sub BUILDARGS {
    my ($class, %args) = @_;

    $args{logger} ||= Pinto::Logger->new( %args );
    $args{config} ||= Pinto::Config->new( %args );

    return \%args;
}


#------------------------------------------------------------------------------
# Builders

sub _build__idxmgr {
    my ($self) = @_;

    return Pinto::IndexManager->new( config => $self->config(),
                                     logger => $self->logger() );
}

#------------------------------------------------------------------------------

sub _build__store {
    my ($self) = @_;

    my $store_class = $self->config->store();

    eval { Class::Load::load_class( $store_class ); 1 }
        or throw_load "Unable to load store class $store_class: $@";

    return $store_class->new( config => $self->config(),
                              logger => $self->logger() );
}

#------------------------------------------------------------------------------
# Public methods

sub new_action_batch {
    my ($self, %args) = @_;

    my $batch = Pinto::ActionBatch->new( config => $self->config(),
                                         logger => $self->logger(),
                                         store  => $self->_store(),
                                         idxmgr => $self->_idxmgr(),
                                         %args );

   $self->_set_action_batch( $batch );

   return $self;
}

#------------------------------------------------------------------------------

sub add_action {
    my ($self, $action_name, %args) = @_;

    my $action_class = "Pinto::Action::$action_name";

    eval { Class::Load::load_class($action_class); 1 }
        or throw_load "Unable to load action class $action_class: $@";

    my $action =  $action_class->new( config => $self->config(),
                                      logger => $self->logger(),
                                      idxmgr => $self->_idxmgr(),
                                      store  => $self->_store(),
                                      %args );

    $self->_action_batch->enqueue($action);

    return $self;
}

#------------------------------------------------------------------------------

sub run_actions {
    my ($self) = @_;

    my $action_batch = $self->_action_batch()
      or throw_args 'You must create an action batch first';

    return $self->_action_batch->run();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems PASSed cpan testmatrix
url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders

=head1 NAME

Pinto - Perl distribution repository manager

=head1 VERSION

version 0.021

=head1 SYNOPSIS

There is nothing for you to see here. Instead, please look at one or
more of the following:

See L<Pinto::Manual> for broad information about the Pinto tools.

See L<pinto-admin> to create and manage your Pinto repository.

See L<pinto-server> to allow remote access to your Pinto repository.

See L<pinto-remote> to interact with a remote Pinto repository.

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Pinto

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Pinto>

=item *

RT: CPAN's Bug Tracker

The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pinto>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Pinto>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/P/Pinto>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual way to determine what Perls/platforms PASSed for a distribution.

L<http://matrix.cpantesters.org/?dist=Pinto>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=Pinto>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-pinto at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pinto>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code


L<https://github.com/thaljef/Pinto>

  git clone https://github.com/thaljef/Pinto

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

