package Pinto::Index;

# ABSTRACT: Represents an 02packages.details.txt file

use Moose;
use Moose::Autobox;

use MooseX::Types::Moose qw(HashRef);

use Carp;
use Compress::Zlib;
use Path::Class qw();

use Pinto::Package;
use Pinto::Types qw(File);

use overload ('+' => '__plus', '-' => '__minus');

#------------------------------------------------------------------------------

our $VERSION = '0.006'; # VERSION

#------------------------------------------------------------------------------


has packages => (
    is         => 'ro',
    isa        => HashRef,
    init_arg   => undef,
    lazy_build => 1,
);

has files => (
    is         => 'ro',
    isa        => HashRef,
    init_arg   => undef,
    lazy_build => 1,
);

has 'file' => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
);

#------------------------------------------------------------------------------
# Moose roles

with qw(Pinto::Role::Loggable);

#------------------------------------------------------------------------------

sub _build_packages { return {} }

sub _build_files    { return {} }

#------------------------------------------------------------------------------

sub BUILD {
    my ($self) = @_;

    $self->load() if $self->file();

    return $self;
}

#------------------------------------------------------------------------------
# Methods

sub load {
    my ($self) = @_;

    my $file = $self->file();
    $self->logger->debug("Reading index at $file");

    my $fh = $file->openr();
    my $gz = Compress::Zlib::gzopen($fh, "rb")
        or croak "Cannot open $file: $Compress::Zlib::gzerrno";

    my $inheader = 1;
    while ($gz->gzreadline($_) > 0) {

        if ($inheader) {
            $inheader = 0 if not /\S/;
            next;
        }

        chomp;
        my ($name, $version, $file) = split;

        $self->add( Pinto::Package->new( name    => $name,
                                         file    => $file,
                                         version => $version ) );

    }

    return $self;
}

#------------------------------------------------------------------------------


sub write {
    my ($self, %args) = @_;

    # TODO: Accept a file handle argument

    my $file = $args{file} || $self->file()
        or croak 'This index has no file attribute, so you must specify one';

    $file = Path::Class::file($file) unless eval { $file->isa('Path::Class::File') };
    $self->logger->debug("Writing index at $file");

    $file->dir->mkpath(); # TODO: log & error check
    my $gz = Compress::Zlib::gzopen( $file->openw(), 'wb' );
    $self->_gz_write_header($gz);
    $self->_gz_write_packages($gz);
    $gz->gzclose();

    return $self;
}

#------------------------------------------------------------------------------

sub _gz_write_header {
    my ($self, $gz) = @_;

    my ($file, $url) = $self->file()
        ? ($self->file->basename(), 'file://' . $self->file->as_foreign('Unix') )
        : ('UNKNOWN', 'UNKNOWN');

    $gz->gzwrite( <<END_PACKAGE_HEADER );
File:         $file
URL:          $url
Description:  Package names found in directory \$CPAN/authors/id/
Columns:      package name, version, path
Intended-For: Automated fetch routines, namespace documentation.
Written-By:   Pinto::Index 0.01
Line-Count:   @{[ $self->package_count() ]}
Last-Updated: @{[ scalar localtime() ]}

END_PACKAGE_HEADER

    return $self;
}

#------------------------------------------------------------------------------

sub _gz_write_packages {
    my ($self, $gz) = @_;

    my $sorter = sub { $_[0]->{name} cmp $_[1]->{name} };
    my $packages = $self->packages->values->sort($sorter);
    for my $package ( $packages->flatten() ) {
        $gz->gzwrite($package->to_string() . "\n");
    }

    return $self;
}

#------------------------------------------------------------------------------


sub merge {
    my ($self, @packages) = @_;

    $self->remove( @packages );
    $self->add( @packages );

    return $self;
}

#------------------------------------------------------------------------------


sub add {
    my ($self, @packages) = @_;

    for my $package (@packages) {
        my $name = $package->name();
        $self->packages->put($name, $package);

        my $file = $package->file();
        ($self->files()->{$file} ||= [] )->push($package);
    }

    return $self;
}

#------------------------------------------------------------------------------


sub reload {
    my ($self) = @_;

    $self->clear();
    $self->load();

    return $self;
}

#------------------------------------------------------------------------------


sub clear {
    my ($self) = @_;

    $self->clear_packages();
    $self->clear_files();

    return $self;
}

#------------------------------------------------------------------------------


sub remove {
    my ($self, @packages) = @_;

    my @removed = ();
    for my $package (@packages) {

        $package = $package->name()
            if eval { $package->isa('Pinto::Package') };

        if (my $incumbent = $self->packages->at($package)) {
            # Remove the file that contains the incumbent package and
            # then remove all packages that were contained in that file
            my $kin = $self->files->delete( $incumbent->file() );
            $self->packages->delete($_) for map {$_->name()} @{ $kin };
            push @removed, @{ $kin };
        }

    }
    return @removed;
}

#------------------------------------------------------------------------------


sub package_count {
    my ($self) = @_;

    return $self->packages->keys->length();
}

#------------------------------------------------------------------------------

sub find {
    my ($self, %args) = @_;

    if (my $pkg = $args{package}) {
        return $self->packages->at($pkg);
    }
    elsif (my $file = $args{file}) {
        my $pkgs = $self->files->at($file);
        return $pkgs ? $pkgs->flatten() : ();
    }
    elsif (my $author = $args{author}) {
        my $filter = sub { $_[0]->file() eq $author };
        return $self->packages->values->grep( $filter )->flatten();
    }

    croak "Don't know how to find by %args";
}

#------------------------------------------------------------------------------

sub __plus {
    my ($self, $other, $swap) = @_;

    ($self, $other) = ($other, $self) if $swap;
    my $class = ref $self;
    my $result = $class->new( logger => $self->logger() );
    $result->add( $self->packages->values->flatten() );
    $result->merge( $other->packages->values->flatten() );

    return $result;
}

#------------------------------------------------------------------------------

sub __minus {
    my ($self, $other, $swap) = @_;

    ($self, $other) = ($other, $self) if $swap;
    my $class = ref $self;
    my $result = $class->new( logger => $self->logger() );
    $result->add( $self->packages->values->flatten() );
    $result->remove( $other->packages->values->flatten() );

    return $result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta()->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Index - Represents an 02packages.details.txt file

=head1 VERSION

version 0.006

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 ATTRIBUTES

=head2 packages()

Returns a reference to hash of packages listed in this index.  The
keys are packages names (as strings) and the values are the associated
L<Pinto::Package> objects.

=head2 write(file => '02packages.details.txt.gz')

Writes this Index to file in the format of the
F<02packages.details.txt> file.  The file will also be C<gzipped>.  If
the C<file> argument is not explicitly given here, the name of the
file is taken from the C<file> attribute for this Index.

=head2 merge( @packages )

Adds a list of L<Pinto::Package> objects to this Index, and removes
any existing packages that conflict with the added ones.  Use this
method when combining an Index of private packages with an Index of
public packages.

=head2 add( @packages)

Unconditionally adds a list of L<Pinto::Package> objects to this
Index.  If the index already contains packages by the same name, they
will be overwritten.

=head1 METHODS

=head2 reload()

Clears all the packages in this Index and reloads them from the file
specified by the C<file> attribute.

=head2 clear()

Removes all packages from this Index.

=head2 remove( @packages )

Removes the packages from the index.  Whenever a package is removed, all
the other packages that belonged in the same archive are also removed.
Arguments can be L<Pinto::Package> objects or package names as strings.

=head2 package_count()

Returns the total number of packages currently in this Index.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__





