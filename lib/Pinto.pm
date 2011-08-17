package Pinto;

# ABSTRACT: Perl distribution repository manager

use Moose;

use Carp;
use Class::Load;
use Path::Class;

use Pinto::ActionFactory;
use Pinto::ActionBatch;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.012'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

# TODO: make private
has action_factory => (
    is        => 'ro',
    isa       => 'Pinto::ActionFactory',
    builder   => '_build_action_factory',
    handles   => [ qw(create_action) ],
    lazy      => 1,
);

#------------------------------------------------------------------------------

# TODO: make private
has action_batch => (
    is         => 'ro',
    isa        => 'Pinto::ActionBatch',
    builder    => '_build_action_batch',
    handles    => [ qw(enqueue run) ],
    lazy       => 1,
);

#------------------------------------------------------------------------------

# TODO: make private
has idxmgr => (
    is       => 'ro',
    isa      => 'Pinto::IndexManager',
    builder  => '_build_idxmgr',
    lazy     => 1,
);

#------------------------------------------------------------------------------

# TODO: make private
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
    croak "A repository already exists at $local"
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

    my $dists = delete $args{dists};
    $dists = [$dists] if ref $dists ne 'ARRAY';

    # TODO: Allow $dist to be a URL (http://, ftp://, file://).

    for my $dist ( @{$dists} ) {
        $self->enqueue( $self->create_action('Add', dist => $dist, %args) );
    }

    $self->run();

    return $self;
}

#------------------------------------------------------------------------------


sub remove {
    my ($self, %args) = @_;

    my $packages = delete $args{packages};
    $packages = [$packages] if ref $packages ne 'ARRAY';

    for my $pkg ( @{$packages} ) {
        $self->enqueue( $self->create_action('Remove', package => $pkg, %args) );
    }

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
    my ($self, %args) = @_;

    $self->enqueue( $self->create_action('List', %args) );
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

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems Genentech Hartzell
Walde Sorichetti PASSed cpan testmatrix url annocpan anno bugtracker rt
cpants kwalitee diff irc mailto metadata placeholders

=head1 NAME

Pinto - Perl distribution repository manager

=head1 VERSION

version 0.012

=head1 SYNOPSIS

You probably want to look at the documentation for L<pinto-admin>.
All the modules in this distribution are private (for now).  So the
API documentation is purely for my own reference.  But this document
does explain what Pinto does and why it exists, so feel free to read
on anyway.

=head1 METHODS

=head2 create()

Creates a new empty repository.

=head2 mirror()

Populates your repository with the latest version of all distributions
found in the foreign repository (which is usually a CPAN mirror).  Your
locally added distributions will always mask those mirrored from the
remote repository.

=head2 add(dists => ['YourDist.tar.gz'], author => 'SOMEONE')

=head2 remove(packages => ['Some::Package'], author => 'SOMEONE')

=head2 clean()

=head2 list()

=head2 verify()

=head1 DISCUSSION

L<Pinto> is a set of tools for creating and managing a CPAN-style
repository.  This repository can contain just your own private
distributions, or you can fill it with the latest ones from a CPAN
mirror, or both.  You can then use your favorite CPAN client to
fetch distributions from your repository and install them as you
normally would.

L<Pinto> shares a lot of DNA with L<CPAN::Site>, L<CPAN::Mini>, and
L<CPAN::Mini::Inject>.  But I wasn't entirely satisfied with those, so
I built a (hopefully better) mousetrap.

L<Pinto> is B<not> magic pixie dust though.  It does not guarantee
that you will always have a working stack of distributions.  It is
still up to you to figure out what to put in your repository.
L<Pinto> just gives you a set of tools for doing that in a controlled
manner.

This is a work in progress.  Comments, criticisms, and suggestions
are always welcome.  Feel free to contact C<thaljef@cpan.org>.

=head1 WHY IS IT CALLED "Pinto"

The term "CPAN" is heavily overloaded.  In some contexts, it means the
L<CPAN> module or the L<cpan> utility.  In other contexts, it means a
mirror like L<http://cpan.perl.org> or a web site like
L<http://search.cpan.org>.

I wanted to avoid all that confusion, so I picked a name that has no
connection to "CPAN" at all.  "Pinto" is a nickname that I sometimes
call my son, Wesley.

=head1 THANKS

=over 4

=item Randal Schwartz - for pioneering the first mini CPAN back in 2002

=item Ricardo Signes - for creating CPAN::Mini, which inspired much of Pinto

=item Shawn Sorichetti & Christian Walde - for creating CPAN::Mini::Inject

=item George Hartzell @ Genentech - for sponsoring this project

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

