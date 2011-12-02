package Pinto;

# ABSTRACT: Curate your own CPAN-like repository

use Moose;

use Class::Load;

use Pinto::Config;
use Pinto::Logger;
use Pinto::Locker;
use Pinto::Batch;
use Pinto::Repository;
use Pinto::Exceptions qw(throw_fatal);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.025_002'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

#------------------------------------------------------------------------------

has repos   => (
    is         => 'ro',
    isa        => 'Pinto::Repository',
    lazy_build => 1,
);


has locker  => (
    is         => 'ro',
    isa        => 'Pinto::Locker',
    init_arg   =>  undef,
    lazy_build => 1,
);


has _batch => (
    is         => 'ro',
    isa        => 'Pinto::Batch',
    writer     => '_set_batch',
    init_arg   => undef,
);


#------------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Interface::Configurable
         Pinto::Interface::Loggable );

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

sub _build_repos {
    my ($self) = @_;

    return Pinto::Repository->new( config => $self->config(),
                                   logger => $self->logger() );
}

#------------------------------------------------------------------------------

sub _build_locker {
    my ($self) = @_;

    return Pinto::Locker->new( config => $self->config(),
                               logger => $self->logger() );
}

#------------------------------------------------------------------------------
# Public methods

sub new_batch {
    my ($self, %args) = @_;

    my $batch = Pinto::Batch->new( config => $self->config(),
                                   logger => $self->logger(),
                                   repos  => $self->repos(),
                                   %args );

   $self->_set_batch( $batch );

   return $self;
}

#------------------------------------------------------------------------------

sub add_action {
    my ($self, $action_name, %args) = @_;

    my $action_class = "Pinto::Action::$action_name";

    eval { Class::Load::load_class($action_class); 1 }
        or throw_fatal "Unable to load action class $action_class: $@";

    my $action =  $action_class->new( config => $self->config(),
                                      logger => $self->logger(),
                                      repos  => $self->repos(),
                                      %args );

    $self->_batch->enqueue($action);

    return $self;
}

#------------------------------------------------------------------------------

sub run_actions {
    my ($self) = @_;

    my $batch = $self->_batch()
        or throw_fatal 'You must create a batch first';

    # Divert any warnings to our logger
    local $SIG{__WARN__} = sub { $self->whine(@_) };

    # Shit happens here!
    $self->locker->lock();
    my $r = $self->_batch->run();
    $self->locker->unlock();

    return $r;

}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems cpan testmatrix url
annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders

=head1 NAME

Pinto - Curate your own CPAN-like repository

=head1 VERSION

version 0.025_002

=head1 SYNOPSIS

See L<pinto-admin> to create and manage a Pinto repository.

See L<pinto-server> to open remote access to a Pinto repository.

See L<pinto-remote> to interact with a remote Pinto repository.

See L<Pinto::Manual> for more information about the Pinto tools.

=head1 DESCRIPTION

L<Pinto> is a suite of tools for creating and managing a CPAN-like
repository of Perl archives.  Pinto is inspired by L<CPAN::Mini>,
L<CPAN::Mini::Inject>, and L<MyCPAN::App::DPAN>, but adds a few
interesting features:

=over 4

=item * Pinto supports several usage patterns

With L<Pinto>, you can create a repository to mirror the latest
distributions from another repository.  Or you can create a "sparse
repository" with just your own private distributions.  Or you can
create a "project repository" that has all the distributions required
for a particular project.  Or you can combine all of the above in some
way.

=item * Pinto supports adding AND removing archives from the repository.

L<Pinto> gives you the power to precisely tune the contents of your
repository.  So you can be sure that your downstream clients get
exactly the stack of dependencies that you want them to have.

=item * Pinto can be integrated with your version control system.

L<Pinto> can automatically commit to your version control system
whenever the contents of the repository changes.  This gives you
repeatable and identifiable snapshots of your dependencies, and a
mechanism for rollback when things go wrong.

=item * Pinto makes it easier to build several local repositories.

Creating new L<Pinto> repositories is easy, and each has its own
configuration.  So you can have different repositories for each
department, or each project, or each version of perl, or each
customer, or whatever you want.

=item * Pinto can pull archives from multiple remote repositories.

L<Pinto> can mirror or import distributions from multiple sources, so
you can create private (or public) networks of repositories that
enable separate teams or individuals to collaborate and share
distributions.

=item * Pinto supports team development.

L<Pinto> is suitable for small to medium-sized development teams,
where several developers might contribute new distributions at the
same time.

=item * Pinto has a robust command line interface.

The L<pinto-admin> and L<pinto-remote> command line tools have options
to control every aspect of your L<Pinto> repository.  They are well
documented and behave in a DWIM fashion.

=item * Pinto can be extended.

You can extend L<Pinto> by creating L<Pinto::Action> subclasses to
perform new operations on your repository, such as extracting
documentation from a distribution, or grepping the source code of
several distributions.

=back

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

L<https://github.com/thaljef/Pinto/issues>

=head2 Source Code


L<https://github.com/thaljef/Pinto>

  git clone git://github.com/thaljef/Pinto.git

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

