package Pinto;

# ABSTRACT: Perl distribution repository manager

use Moose;

use Carp;
use Path::Class;

use Pinto::ActionFactory;
use Pinto::ActionBatch;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.008'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has action_factory => (
    is        => 'ro',
    isa       => 'Pinto::ActionFactory',
    builder   => '_build_action_factory',
    handles   => [ qw(create_action) ],
    lazy      => 1,
);

#------------------------------------------------------------------------------

has action_batch => (
    is         => 'ro',
    isa        => 'Pinto::ActionBatch',
    builder    => '_build_action_batch',
    handles    => [ qw(enqueue run) ],
    lazy       => 1,
);

#------------------------------------------------------------------------------

has idxmgr => (
    is       => 'ro',
    isa      => 'Pinto::IndexManager',
    builder  => '_build_idxmgr',
    lazy     => 1,
);

#------------------------------------------------------------------------------

has store => (
    is       => 'ro',
    isa      => 'Pinto::Store',
    builder  => '_build_store',
    lazy     => 1,
);

#------------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Builders

sub _build_action_factory {
    my ($self) = @_;

    return Pinto::ActionFactory->new( config => $self->config(),
                                      logger => $self->logger(),
                                      idxmgr => $self->idxmgr(),
                                      store  => $self->store() );
}

sub _build_action_batch {
    my ($self) = @_;

    return Pinto::ActionBatch->new( config => $self->config(),
                                    logger => $self->logger(),
                                    idxmgr => $self->idxmgr(),
                                    store  => $self->store() );
}

sub _build_idxmgr {
    my ($self) = @_;

    return Pinto::IndexManager->new( config => $self->config(),
                                     logger => $self->logger() );
}

sub _build_store {
    my ($self) = @_;

    my $store_class = $self->config->store();
    Class::Load::load_class( $store_class );

    return $store_class->new( config => $self->config(),
                              logger => $self->logger() );
}

#------------------------------------------------------------------------------
# Public methods



sub create {
    my ($self) = @_;

    # HACK...I want to do this before checking out from VCS
    my $local = Path::Class::dir( $self->config()->local() );
    die "Looks like you already have a repository at $local\n"
        if -e file($local, qw(modules 02packages.details.txt.gz));

    $self->enqueue( $self->create_action('Create') );
    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub mirror {
    my ($self) = @_;

    $self->enqueue( $self->create_action('Mirror') );
    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub add {
    my ($self, %args) = @_;

    my $file = $args{file};
    $file = [$file] if not ref $file;

    $self->enqueue( $self->create_action('Add', file => $_) ) for @{ $file };
    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub remove {
    my ($self, %args) = @_;

    my $package = $args{package};
    $package = [$package] if not ref $package;

    $self->enqueue( $self->create_action('Remove', package => $_) ) for @{ $package };
    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub clean {
    my ($self) = @_;

    $self->enqueue( $self->create_action('Clean') );
    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub list {
    my ($self) = @_;

    $self->enqueue( $self->create_action('List') );
    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub verify {
    my ($self, %args) = @_;

    $self->enqueue( $self->create_action('Verify') );
    $self->run();

    return $self;
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

Pinto - Perl distribution repository manager

=head1 VERSION

version 0.008

=head1 DESCRIPTION

You probably want to look at the documentation for L<pinto>.  This is
a private module (for now) and the interface is subject to change.  So
the API documentation is purely for my own reference.  But this
document does explain what Pinto does and why it exists, so feel free
to read on anyway.

This is a work in progress.  Comments, criticisms, and suggestions
are always welcome.  Feel free to contact C<thaljef@cpan.org>.

=head1 METHODS

=head2 create()

Creates a new empty repository.

=head2 mirror()

Populates your repository with the latest version of all packages
found on the CPAN mirror.  Your locally added packages will always
mask those pulled from the mirror.

=head2 add(file => 'YourDist.tar.gz', author => 'SOMEONE')

=head2 remove(package => 'Some::Package', author => 'SOMEONE')

=head2 clean()

=head2 list()

=head2 verify()

=head1 TERMINOLOGY

Some of the terms around CPAN are frequently misused.  So for the
purpose of this document, I am going to define some terms.  I am not
saying that these are necessarily the "correct" definitions, but
this is what I mean when I use them.

=over 4

=item package

A "package" is the name that appears in a C<package> statement.  This
is what PAUSE indexes, and this is what you usually ask L<cpan> or
L<cpanm> to install for you.

=item module

A "module" is the name that appears in a C<use> or (sometimes)
C<require> statement, and it always corresponds to a physical file
somewhere.  A module usually contains only one package, and the name
of the module usually matches the name of the package.  But sometimes,
a module may contain many packages with completely arbitrary names.

=item distribution 

An "distribution" is a collection of Perl modules that have been packaged
in a particular structure.  This is what you get when you run C<"make
dist"> or C<"./Build dist">.  Distributions may come from a "mirror",
or you may create your own.

=item repository

A "repository" is a collection of distributions that are organized in a
particular structure, and having an index describing which packages
are contained in each distribution.  This is where L<cpan> and L<cpanm>
get the packages from.

=item mirror

A "mirror" is a copy of a public CPAN repository
(e.g. http://cpan.perl.org).  Every "mirror" is a "repository", but
not every "repository" is a "mirror".

=back

=head1 RULES

There are certain rules that govern how the indexes are managed.
These rules are intended to ensure that folks pulling packages from
your repository will always get the *right* packages (according to my
definitionof "right").  Also, the rules attempt to make Pinto behave
somewhat like PAUSE does.

=over 4

=item A local package always masks a mirrored package, and all other
packages that are in the same distribution with the mirrored package.

This rule is key, so pay attention.  If the CPAN mirror has a distribution
that contains both C<Foo> and C<Bar> packages, and you add your own
distribution that contains C<Foo> package, then both the C<Foo> and C<Bar>
mirroed packages will be removed from your index.  This ensures that
anyone pulling packages from your repository will always get *your*
version of C<Foo>.  But as a result, they'll never be able to get
C<Bar>.

=item You can never add an distribution with the same name twice.

Most distribtuion-building tools will put some kind of version number in
the name of the distribution, so this is rarely a problem.

=item Only the original author of a local package can add a newer
version of it.

Ownership is given on a first-come basis, just like PAUSE.  So if
C<SALLY> is the first author to add local package C<Foo::Bar> to the
repository, then only C<SALLY> can ever add that package again.

=item Only the original author of a local package can remove it.

Just like when adding new versions of a local package, only the
original author can remove it.

=back

=head1 WHY IS IT CALLED "Pinto"

The term "CPAN" is heavily overloaded.  In some contexts, it means the
L<CPAN> module or the L<cpan> utility.  In other contexts, it means a
mirror like L<http://cpan.perl.org> or a site like
L<http://search.cpan.org>.

I wanted to avoid confusion, so I picked a name that has no connection
to "CPAN" at all.  "Pinto" is a nickname that I sometimes call my son,
Wesley.

=head1 TODO

=over 4

=item Enable plugins for visiting and filtering

=item Implement Pinto::Store::Git

=item Fix my Moose abuses

=item Consider storing indexes in a DB, instead of files

=item Automatically fetch dependecies when adding *VERY COOL*

=item New command for listing conflicts between local and mirrored index

=item Make file/directory permissions configurable

=item Need more error checking and logging

=item Lots of tests to write

=back

=head1 THANKS

=over 4

=item Randal Schwartz - for pioneering the first mini CPAN back in 2002

=item Ricardo Signes - for creating CPAN::Mini, which inspired much of Pinto

=item Shawn Sorichetti & Christian Walde - for creating CPAN::Mini::Inject

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

