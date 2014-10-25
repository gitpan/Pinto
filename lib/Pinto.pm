package Pinto;

# ABSTRACT: Curate a repository of Perl modules

use Moose;
use MooseX::Types::Moose qw(Str);

use Try::Tiny;
use Class::Load;

use Pinto::Repository;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.051'; # VERSION

#------------------------------------------------------------------------------

has repos   => (
    is         => 'ro',
    isa        => 'Pinto::Repository',
    lazy       => 1,
    default    => sub { Pinto::Repository->new( config => $_[0]->config,
                                                logger => $_[0]->logger ) },
);


has action_base_class => (
    is         => 'ro',
    isa        => Str,
    default    => 'Pinto::Action',
    init_arg   => undef,
);


#------------------------------------------------------------------------------

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------


sub run {
    my ($self, $action_name, %args) = @_;

    # Divert any warnings to our logger
    local $SIG{__WARN__} = sub { $self->warning(@_) };

    my $action_class = $self->action_base_class . "::$action_name";
    Class::Load::load_class($action_class);

    my $runner = $action_class->does('Pinto::Role::Operator') ?
      '_run_operator' : '_run_reporter';

    my $result = try     { $self->$runner($action_class, %args)   }
                 catch   { $self->repos->unlock; $self->fatal($_) };

    $self->repos->unlock;
    return $result;
}

#------------------------------------------------------------------------------

sub _run_reporter {
    my ($self, $action_class, %args) = @_;

    $self->repos->lock_shared;
    $self->repos->check_schema_version;
    @args{qw(logger repos)} = ($self->logger, $self->repos);
    my $action = $action_class->new( %args );
    my $result = $action->execute;

    return $result;

}

#------------------------------------------------------------------------------

sub _run_operator {
    my ($self, $action_class, %args) = @_;

    $self->repos->lock_exclusive;
    $self->repos->check_schema_version;
    $self->repos->db->schema->txn_begin;

    my $result = try {
        @args{qw(logger repos)} = ($self->logger, $self->repos);
        my $action = $action_class->new( %args );
        my $res    = $action->execute;

        if ($action->dryrun) {
            $self->notice('Dryrun -- rolling back database');
            $self->repos->db->schema->txn_rollback;
        }
        elsif ( not $res->made_changes ) {
            $self->notice('No changes were made');
            $self->repos->db->schema->txn_rollback;
        }
        else {

            # We only need to update the static index file if changes
            # were made on the stack that the file represents (i.e. it
            # is the default stack).  If the $operative_stack is not
            # defined, then it is the default stack by definition.

            my $operative_stack = $action->operative_stack;
            my $default_stack   = $self->repos->get_default_stack->name;

            $self->repos->write_index if not defined $operative_stack
                or $operative_stack eq $default_stack;

            $self->repos->db->schema->txn_commit;
        }

        $res; # returned from try{}
    }
    catch {
        $self->repos->db->schema->txn_rollback;
        die $_;        ## no critic qw(Carping)
    };

    return $result;
}

#------------------------------------------------------------------------------


sub add_logger {
    my ($self, @args) = @_;

    $self->logger->add_output(@args);

    return $self;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems cpan testmatrix url
annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders metacpan

=head1 NAME

Pinto - Curate a repository of Perl modules

=head1 VERSION

version 0.051

=head1 SYNOPSIS

See L<pinto> to create and manage a Pinto repository.

See L<pintod> to allow remote access to your Pinto repository.

See L<Pinto::Manual> for more information about the Pinto tools.

=head1 DESCRIPTION

Pinto is a suite of tools and libraries for creating and managing a
custom CPAN-like repository of Perl modules.  The purpose of such a
repository is to provide a stable, curated stack of dependencies from
which you can reliably build, test, and delploy your application using
the standard Perl tool chain. Pinto supports various operations for
gathering and managing distribution dependencies within the
repository, so that you can control precisely which dependencies go
into your application.

=head1 METHODS

=head2 run( $action_name => %action_args )

Runs the Action with the given C<$action_name>, passing the
C<%action_args> to its constructor.  Returns a L<Pinto::Result>.

=head2 add_logger( $obj )

Convenience method for installing additional endpoints for logging.
The object must be an instance of a L<Log::Dispatch::Output> subclass.

=head1 FEATURES

Pinto is inspired by L<Carton>, L<CPAN::Mini::Inject>, and
L<MyCPAN::App::DPAN>, but adds a few interesting features:

=over 4

=item * Pinto supports mutiple indexes

A Pinto repository can have multiple indexes.  Each index corresponds
to a "stack" of dependencies that you can control.  So you can have
one stack for development, one for production, one for feature-xyz,
and so on.  You can also branch and merge stacks to experiment with
new dependencies or upgrades.

=item * Pinto helps manage incompatibilies between dependencies

Sometimes, you discover that a new version of a dependency is
incompatible with your application.  Pinto allows you to "pin" a
dependency to a stack, which prevents it from being accidentally
upgraded (either directly or via some other dependency).

=item * Pinto can pull archives from multiple remote repositories

Pinto can pull dependencies from multiple sources, so you can create
private (or public) networks of repositories that enable separate
teams or individuals to collaborate and share Perl modules.

=item * Pinto supports team development

Pinto is suitable for small to medium-sized development teams and
supports concurrent users.  Pinto also has a web service interface
(via L<pintod>), so remote developers can use a centrally hosted
repository.

=item * Pinto has a robust command line interface.

The L<pinto> utility has commands and options to control every aspect
of your Pinto repository.  They are well documented and behave in the
customary UNIX fashion.

=item * Pinto can be extended.

You can extend Pinto by creating L<Pinto::Action> subclasses to
perform new operations on your repository, such as extracting
documentation from a distribution, or grepping the source code of
several distributions.

=back

=head1 Pinto vs PAUSE

In some ways, Pinto is similar to L<PAUSE|http://pause.perl.org>.
Both are capable of accepting distributions and constructing a
directory structure and index that Perl installers understand.  But
there are some important differences:

=over

=item * Pinto does not promise to index exactly like PAUSE does

Over the years, PAUSE has evolved complicated heuristics for dealing
with all the different ways that Perl code is written and packaged.
Pinto is much less sophisticated, and only aspires to produce an index
that is "good enough" for most situations.

=item * Pinto does not understand author permissions

PAUSE has a system of assigning ownership and co-maintenance
permission of modules to specific people.  Pinto does not have any
such permission system.  All activity is logged so you can identify
the culprit, but Pinto expects you to be accountable for your actions.

=item * Pinto is not (always) secure

PAUSE requires authors to authenticate themselves before they can
upload or remove modules.  Pinto does not require authentication, so
any user with sufficient file permission can potentialy change the
repository.  However L<pintod> does suport HTTP authentication, which
gives you some control over access to a remote repository.

=back

=head1 BUT WHERE IS THE API?

For now, the Pinto API is private and subject to radical change
without notice.  Any API documentation you see is purely for my own
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

