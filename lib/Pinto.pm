package Pinto;

# ABSTRACT: Perl archive repository manager

use Moose;

use Pinto::Util;
use Pinto::Index;
use Pinto::Config;
use Pinto::UserAgent;

use Carp;
use File::Copy;
use File::Find;
use Dist::Metadata;
use Path::Class;
use Class::Load;
use URI;

#------------------------------------------------------------------------------

our $VERSION = '0.001'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes


has 'config' => (
    is       => 'ro',
    isa      => 'Pinto::Config',
    required => 1,
);

has '_store' => (
    is       => 'ro',
    isa      => 'Pinto::Store',
    builder  => '__build_store',
    init_arg => undef,
    lazy     => 1,
);

has '_ua'      => (
    is         => 'ro',
    isa        => 'Pinto::UserAgent',
    default    => sub { Pinto::UserAgent->new() },
    handles    => [qw(mirror)],
    init_arg   => undef,
);


has 'remote_index' => (
    is             => 'ro',
    isa            => 'Pinto::Index',
    builder        => '__build_remote_index',
    init_arg       => undef,
    lazy           => 1,
);


has 'local_index'   => (
    is              => 'ro',
    isa             => 'Pinto::Index',
    builder         => '__build_local_index',
    init_arg        => undef,
    lazy            => 1,
);


has 'master_index'  => (
    is              => 'ro',
    isa             => 'Pinto::Index',
    builder         => '__build_master_index',
    init_arg        => undef,
    lazy            => 1,
);

#------------------------------------------------------------------------------
# Roles

with 'Pinto::Role::Log';

#------------------------------------------------------------------------------
# Builders

sub __build_remote_index {
    my ($self) = @_;

    return $self->__build_index(file => '02packages.details.remote.txt.gz');
}

#------------------------------------------------------------------------------

sub __build_local_index {
    my ($self) = @_;

    return $self->__build_index(file => '02packages.details.local.txt.gz');
}

#------------------------------------------------------------------------------

sub __build_master_index {
    my ($self) = @_;

    return $self->__build_index(file => '02packages.details.txt.gz');
}

#------------------------------------------------------------------------------

sub __build_index {
    my ($self, %args) = @_;

    my $local = $self->config()->get_required('local');
    my $index_file = file($local, 'modules', $args{file});
    $self->log->debug("Reading index $index_file");

    return Pinto::Index->new(file => $index_file);
}

#------------------------------------------------------------------------------

sub __build_store {
   my ($self) = @_;

   my $store_class = $self->config()->get('store_class') || 'Pinto::Store';
   Class::Load::load_class($store_class);

   return $store_class->new( config => $self->config() );
}

#------------------------------------------------------------------------------
# Private methods

sub _rebuild_master_index {
    my ($self) = @_;


    # Do this first, to kick lazy builders which also causes
    # validation on the configuration.  Then we can log...
    $self->master_index()->clear();

    $self->log()->debug("Building master index");

    $self->master_index()->add( @{$self->remote_index()->packages()} );
    $self->master_index()->merge( @{$self->local_index()->packages()} );

    $self->master_index()->write();

    return $self;
}

#------------------------------------------------------------------------------
# Public methods


sub create {
    my ($self, %args) = @_;

    my $local = $args{local} || $self->config->get_required('local');

    $self->_store()->initialize();

    if (-e $self->master_index()->file()) {
      $self->log->info("Repository already exists at $local");
      return $self;
    }

    $self->_rebuild_master_index();

    $self->_store()->finalize(message => 'Created new Pinto');

    return $self;
}

#------------------------------------------------------------------------------


sub update {
    my ($self, %args) = @_;

    $self->_store()->initialize();

    my $local  = $args{local}  || $self->config()->get_required('local');
    my $remote = $args{remote} || $self->config()->get_required('remote');

    my $remote_index_uri = URI->new("$remote/modules/02packages.details.txt.gz");
    $self->mirror(url => $remote_index_uri, to => $self->remote_index()->file());
    $self->remote_index()->reload();

    # TODO: Stop now if index has not changed, unless -force option is given.

    my $changes = 0;
    my $mirrorable_index = $self->remote_index() - $self->local_index();

    for my $file ( @{ $mirrorable_index->files() } ) {
        $self->log()->debug("Mirroring $file");
        my $remote_uri = URI->new( "$remote/authors/id/$file" );
        my $destination = Pinto::Util::native_file($local, 'authors', 'id', $file);
        my $changed = $self->mirror(url => $remote_uri, to => $destination);
        $self->log->info("Updated $file") if $changed;
        $changes += $changed;
    }

    $self->_rebuild_master_index();

    my $message = "Updated to latest mirror of $remote";
    $self->_store()->finalize(message => $message);

    return $self;
}

#------------------------------------------------------------------------------


sub add {
    my ($self, %args) = @_;

    $self->_store()->initialize();

    my $local  = $args{local}  || $self->config->get_required('local');
    my $author = $args{author} || $self->config->get_required('author');
    my $file   = $args{file}   or croak 'Must specify a file argument';

    $file = file($file) if not eval { $file->isa('Path::Class::File') };

    my $author_dir    = Pinto::Util::directory_for_author($author);
    my $file_in_index = file($author_dir, $file->basename())->as_foreign('Unix');

    if (my $existing_file = $self->local_index()->packages_by_file->{$file_in_index}) {
        croak "File $file_in_index already exists in the local index";
    }

    # Dist::Metadata will croak for us if $file is whack!
    my $distmeta = Dist::Metadata->new(file => $file);
    my $provides = $distmeta->package_versions();
    return if not %{ $provides };



    my @conflicts = ();
    for my $package_name (keys %{ $provides }) {
        if ( my $incumbent_package = $self->local_index()->packages_by_name()->{$package_name} ) {
            my $incumbent_author = $incumbent_package->author();
            push @conflicts, "Package $package_name is already owned by $incumbent_author\n"
                if $incumbent_author ne $author;
        }
    }
    die @conflicts if @conflicts;


    my @packages = ();
    while( my ($package_name, $version) = each %{ $provides } ) {
        $self->log->info("Adding $package_name $version");
        push @packages, Pinto::Package->new(name => $package_name,
                                            version => $version,
                                            file => "$file_in_index");
    }

    $self->local_index->add(@packages);
    $self->local_index()->write();

    my $destination_dir = Pinto::Util::directory_for_author($local, qw(authors id), $author);
    $destination_dir->mkpath();  #TODO: log & error check
    copy($file, $destination_dir); #TODO: log & error check

    $self->_rebuild_master_index();

    my $message = "Added local archive $file_in_index";
    $self->_store->finalize(message => $message);

    return $self;
}

#------------------------------------------------------------------------------


sub remove {
    my ($self, %args) = @_;

    $self->_store()->initialize();

    my $local  = $args{local}  || $self->config()->get_required('local');
    my $author = $args{author} || $self->config()->get_required('author');
    my $package_name = $args{package} or croak 'Must specify a package argument';

    my $incumbent_package = $self->local_index()->packages_by_name->{$package_name};

    if ($incumbent_package) {
        my $incumbent_author = $incumbent_package->author();
        die "Only author $incumbent_author can remove package $package_name.\n"
            if $incumbent_author ne $author;
    }
    else {
        $self->log()->info("$package_name is not in the local index");
    }

    # TODO: Log only after writing the index, in case of error.

    my @local_removed = $self->local_index()->remove($package_name);
    $self->log->info("Removed $_ from local index") for @local_removed;
    $self->local_index()->write();

    my @master_removed = $self->master_index()->remove($package_name);
    $self->log->info("Removed $_ from master index") for @master_removed;
    $self->master_index()->write();

    # Do not rebuild master index after removing packages,
    # or else the packages from the remote index will appear.

    my $message = "Removed local packages " . join ', ', @local_removed;
    $self->_store()->finalize(message => $message);

    return $self;
}

#------------------------------------------------------------------------------


sub clean {
    my ($self, %args) = @_;

    $self->_store()->initialize();

    my $local = $args{local} || $self->config()->get_required('local');

    my $base_dir = dir($local, qw(authors id));
    return if not -e $base_dir;

    my $wanted = sub {

        my $physical_file = file($File::Find::name);
        my $index_file  = $physical_file->relative($base_dir)->as_foreign('Unix');

        # TODO: Can we just use $_ instead of calling basename() ?
        if (Pinto::Util::is_source_control_file( $physical_file->basename() )) {
            $File::Find::prune = 1;
            return;
        }

        return if not -f $physical_file;
        return if exists $self->master_index()->packages_by_file()->{$index_file};
        $self->log()->info("Cleaning $index_file"); # TODO: report as physical file instead?
        $physical_file->remove(); # TODO: Error check!
    };

    # TODO: Consider using Path::Class::Dir->recurse() instead;
    File::Find::find($wanted, $base_dir);

    my $message = 'Cleaned up archives not found in the index.';
    $self->_store()->finalize(message => $message);

    return $self;
}

#------------------------------------------------------------------------------


sub list {
    my ($self) = @_;

    $self->_store()->initialize();

    for my $package ( @{ $self->master_index()->packages() } ) {
        # TODO: Report native paths instead?
        print $package->to_string(), "\n";
    }

    return $self;
}

#------------------------------------------------------------------------------


sub verify {
    my ($self, %args) = @_;

    $self->_store()->initialize();

    my $local = $args{local} || $self->config()->get_required('local');

    my @base = ($local, 'authors', 'id');
    for my $file ( @{ $self->master_index()->files_native(@base) } ) {
        # TODO: Report absolute or relative path?
        print "$file is missing\n" if not -e $file;
    }

    return $self;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems cpan testmatrix url
annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders

=head1 NAME

Pinto - Perl archive repository manager

=head1 VERSION

version 0.001

=head1 DESCRIPTION

You probably want to look at the documentation for L<pinto>.  This is
a private module (for now) and the interface is subject to change.  So
the API documentation is purely for my own reference.  But this
document does explain what Pinto does and why it exists, so feel free
to read on anyway.

This is a work in progress.  Comments, criticisms, and suggestions
are always welcome.  Feel free to contact C<thaljef@cpan.org>.

=head1 ATTRIBUTES

=head2 config

Returns the L<Pinto::Config> object for this Pinto.  You must provide
one through the constructor.

=head2 remote_index

Returns the L<Pinto::Index> that represents our copy of the
F<02packages> file from a CPAN mirror (or possibly another Pinto
repository).  This index will include the latest versions of all the
packages on the mirror.

=head2 local_index

Returns the L<Pinto::Index> that represents the F<02packages> file for
your local packages.  This index will include only those packages that
you've locally added to the repository.

=head2 master_index

Returns the L<Pinto::Index> that is the logical combination of
packages from both the remote and local indexes.  See the L<"RULES">
section below for information on how the indexes are combined.

=head1 METHODS

=head2 create()

Creates a new empty repoistory.

=head2 update(remote => 'http://cpan-mirror')

Populates your repository with the latest version of all packages
found on the CPAN mirror.  Your locally added packages will always
override those on the mirror.

=head2 add(author => 'YOUR_ID', file => 'YourDist.tar.gz')

Adds your own Perl archive to the repository.  This could be a
proprietary or personal archive, or it could be a patched version of
an archive from a CPAN mirror.  See the L<"RULES"> section for
information about how your archives are combined with those from the
CPAN mirror.

=head2 remove(author => 'YOUR_ID', package => 'Some::Package')

Removes packages from the local index.  When a package is removed, all
other packages that were contained in the same archive are also
removed.  You can only remove a package if you are the author of that
package.

=head2 clean()

Deletes any archives in the repository that are not currently
represented in the master index.  You will usually want to run this
after performing an C<"update">, C<"add">, or C<"remove"> operation.

=head2 list()

Prints a listing of all the packages and archives in the master index.
This is basically what the F<02packages> file looks like.

=head2 verify()

Prints a listing of all the archives that are in the master index, but
are not present in the repository.  This is usually a sign that things
have gone wrong.

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

=item archive

An "archive" is a collection of Perl modules that have been packaged
in a particular structure.  This is what you get when you run C<"make
dist"> or C<"./Build dist">.  Archives may come from a "mirror",
or you may create your own. An archive is the "A" in "CPAN".

=item repository

A "repository" is a collection of archives that are organized in a
particular structure, and having an index describing which packages
are contained in each archive.  This is where L<cpan> and L<cpanm>
get the packages from.

=item mirror

A "mirror" is a copy of a public CPAN repository
(e.g. http://cpan.perl.org).  Every "mirror" is a "repository", but
not every "repository" is a "mirror".

=back

=head1 RULES

There are certain rules that govern how the indexes are managed.
These rules are intended to ensure that folks pulling packages
from your repository will always get the *right  Also,
the rules attempt to make Pinto behave somewhat like PAUSE does.

=over 4

=item A local package always masks a mirrored package, and all other
packages that are in the same archive with the mirrored package.

This rule is key, so pay attention.  If the CPAN mirror has an archive
that contains both C<Foo> and C<Bar> packages, and you add your own
archive that contains C<Foo> package, then both the C<Foo> and C<Bar>
mirroed packages will be removed from your index.  This ensures that
anyone pulling packages from your repository will always get *your*
C<Foo>.  But they'll never be able to get C<Bar>.

If this rule were not in place, someone could pull C<Bar> from the
repository, which would overwrite the version of C<Foo> that you
wanted them to have.  This situation is probably rare, but it can
happen if you add a locally patched version of a mirrored archive, but
the mirrored archive later includes additional packages.

=item You can never add an archive with the same name twice.

Most archive-building tools will put some kind of version number in
the name of the archive, so this is rarely a problem.

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
to "CPAN".  "Pinto" is a nickname that I sometimes call my son,
Wesley.

=head1 TODO

=over 4

=item Enable plugins for visiting and filtering

=item Implement Pinto::Store::Git

=item Fix my Moose abuses

=item Consider storing indexes in a DB, instead of files

=item Automatically fetch dependecies when adding *VERY COOL*

=item New command for listing conflicts between local and remote index

=item Make file/directory permissions configurable

=item Refine terminology: consider "distribution" instead of "archive"

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

