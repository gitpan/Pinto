package Pinto;

# ABSTRACT: Curate your own CPAN-like repository

use Moose;
use MooseX::Types::Moose qw(Bool Str);

use Carp;
use Try::Tiny;
use Class::Load;

use Pinto::Config;
use Pinto::Logger;
use Pinto::Batch;
use Pinto::Repository;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.037'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has repos   => (
    is         => 'ro',
    isa        => 'Pinto::Repository',
    builder    => '_build_repos',
    lazy       => 1,
);


has _batch => (
    is         => 'ro',
    isa        => 'Pinto::Batch',
    writer     => '_set_batch',
    init_arg   => undef,
);


has _action_base_class => (
    is         => 'ro',
    isa        => Str,
    default    => 'Pinto::Action',
    init_arg   => undef,
);


#------------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Construction

sub BUILD {
    my ($self) = @_;

    unless (    -e $self->config->db_file()
             && -e $self->config->modules_dir()
             && -e $self->config->authors_dir() ) {

      my $root_dir = $self->config->root_dir();
      $self->fatal("Directory $root_dir does not look like a Pinto repository");
    }

    return $self;
}

#------------------------------------------------------------------------------
# Builders

sub _build_repos {
    my ($self) = @_;

    return Pinto::Repository->new( config => $self->config(),
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

    my $batch = $self->_batch()
        or confess 'You must create a batch first';

    my $action_class = $self->_action_base_class . "::$action_name";
    Class::Load::load_class($action_class);

    my $action =  $action_class->new( config => $self->config(),
                                      logger => $self->logger(),
                                      repos  => $self->repos(),
                                      %args );

    $batch->enqueue($action);

    return $self;
}

#------------------------------------------------------------------------------


sub run_actions {
    my ($self) = @_;

    my $batch = $self->_batch()
        or confess 'You must create a batch first';

    my $result = try   { $self->_batch->run() }
                 catch { $self->fatal($_)     };

    return $result;

}

#------------------------------------------------------------------------------


sub add_logger {
    my ($self, @args) = @_;

    $self->logger->add_output(@args);

    return $self;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems cpan testmatrix url
annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders metacpan

=head1 NAME

Pinto - Curate your own CPAN-like repository

=head1 VERSION

version 0.037

=head1 SYNOPSIS

See L<pinto-admin> to create and manage a Pinto repository.

See L<pinto-server> to open remote access to a Pinto repository.

See L<pinto-remote> to interact with a remote Pinto repository.

See L<Pinto::Manual> for more information about the Pinto tools.

=head1 DESCRIPTION

Pinto is a suite of tools for creating and managing a CPAN-like
repository of Perl archives.  Pinto is inspired by L<CPAN::Mini>,
L<CPAN::Mini::Inject>, and L<MyCPAN::App::DPAN>, but adds a few
interesting features:

=over 4

=item * Pinto supports several usage patterns

With Pinto, you can create a repository to mirror all the latest
distributions from another repository.  Or you can create a "sparse
repository" with just your own private distributions.  Or you can
create a "project repository" that has all the distributions required
for a particular project.  Or you can combine any of the above in some
way.

=item * Pinto supports adding AND removing archives from the repository

Pinto gives you the power to precisely tune the contents of your
repository.  So you can be sure that your downstream clients get
exactly the stack of dependencies that you want them to have.

=item * Pinto can be integrated with your version control system

Pinto can automatically commit to your version control system whenever
the contents of the repository changes.  This gives you repeatable and
identifiable snapshots of your dependencies, and a mechanism for
rollback when things go wrong.

=item * Pinto makes it easier to build several local repositories

Creating new Pinto repositories is easy, and each has its own
configuration.  So you can have different repositories for each
department, or each project, or each version of perl, or each
customer, or whatever you want.

=item * Pinto can pull archives from multiple remote repositories

Pinto can mirror or import distributions from multiple sources, so you
can create private (or public) networks of repositories that enable
separate teams or individuals to collaborate and share distributions.

=item * Pinto supports team development

Pinto is suitable for small to medium-sized development teams, where
several developers might contribute new distributions at the same
time.  Pinto ensures that concurrent users don't step on each other.

=item * Pinto has a robust command line interface.

The L<pinto-admin> and L<pinto-remote> command line tools have options
to control every aspect of your Pinto repository.  They are well
documented and behave in the customary UNIX fashion.

=item * Pinto can be extended.

You can extend Pinto by creating L<Pinto::Action> subclasses to
perform new operations on your repository, such as extracting
documentation from a distribution, or grepping the source code of
several distributions.

=back

In some ways, Pinto is also similar to L<PAUSE|http://pause.perl.org>.
Both are capable of accepting distributions and constructing a
directory structure and index that toolchain clients understand.  But
there are some important differences:

=over

=item * Pinto does not promise to index exactly like PAUSE does

Over the years, PAUSE has evolved complicated heuristics for dealing
with all the different ways that Perl code is written and
distributions are organized.  Pinto is much less sophisticated, and
only aspires to produce an index that is "good enough" for most
applications.

=item * Pinto does not understand author permissions

PAUSE has a system of assigning ownership and co-maintenance
permission to individuals or groups.  But Pinto only has a basic
"first-come" system of ownership.  The ownership controls are only
advisory and can easily be bypassed (see next item below).

=item * Pinto is not secure

PAUSE requires authors to authenticate themselves before they can
upload or remove distributions.  However, Pinto does not authenticate
and permits users masquerade as anybody they want to be.  This is
actually intentional and designed to encourage collaboration among
developers.

=back

=head1 METHODS

=head2 new_batch( %batch_args )

Prepares this Pinto to run a new batch of Actions.  Any prior batch will
be discarded.

=head2 add_action( $action_name, %action_args )

Constructs the action with the given names and arguments, and adds it
to the current batch.  You must first call C<new_batch> before you can
add any actions.  The precise class of the Action will be formed by
prepending 'Pinto::Action::' to the action name.  See the
documentation for the corresponding Action class for a details about
the arguments it supports.

=head2 run_actions()

Executes all the actions that are currently in the batch for this
Pinto.  Returns a L<Pinto::Result> object that indicates whether the
batch was successful and contains any warning or error messages that
might have occurred along the way.

=head2 add_logger( $obj )

Convenience method for installing additional endpoints for logging.
The object must be an instance of a L<Log::Dispatch::Output> subclass.

=head1 BUT WHERE IS THE API?

For now, the Pinto API is private and subject to radical change
without notice.  Any module documentation you see is purely for my own
references.  In the meantime, the command line utilities mentioned in
the L</SYNOPSIS> are your public user interface.

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

The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

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

