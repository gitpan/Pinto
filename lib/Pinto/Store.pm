# ABSTRACT: Base class for storage of a Pinto repository

package Pinto::Store;

use Moose;

use Try::Tiny;
use CPAN::Checksums;

use Pinto::Exception;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.059'; # VERSION

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable
         Pinto::Role::FileFetcher );

#------------------------------------------------------------------------------
# TODO: Use named arguments here...

sub add_archive {
    my ($self, $origin, $destination) = @_;

    throw "$origin does not exist"      if not -e $origin;
    throw "$origin is not a file"       if not -f $origin;

    $self->fetch(from => $origin, to => $destination);
    $self->update_checksums(directory => $destination->parent);

    return $self;

}

#------------------------------------------------------------------------------
# TODO: Use named arguments here...

sub remove_archive {
    my ($self, $archive_file) = @_;

    $self->remove_path( path => $archive_file );

    $self->update_checksums( directory => $archive_file->parent() );

    return $self;
}

#------------------------------------------------------------------------------

sub remove_path {
    my ($self, %args) = @_;

    my $path = $args{path};
    throw "Must specify a path" if not $path;

    return if not -e $path;

    $path->remove or throw "Failed to remove path $path: $!";

    while (my $dir = $path->parent) {
        last if $dir->children;
        $self->debug("Removing empty directory $dir");
        $dir->remove or throw "Failed to remove directory $dir: $!";
        $path = $dir;
    }

    return $self;
}

#------------------------------------------------------------------------------

sub update_checksums {
    my ($self, %args) = @_;
    my $dir = $args{directory};

    #return 0 if not -e $dir;  # Smells fishy

    my @children = grep { ! Pinto::Util::is_vcs_file($_) } $dir->children;
    return 0 if not @children;

    my $cs_file = $dir->file('CHECKSUMS');

    if ( -e $cs_file && @children == 1 ) {
        $self->remove_path(path => $cs_file);
        return 0;
    }

    $self->debug("Generating $cs_file");

    try   { CPAN::Checksums::updatedir($dir) }
    catch { throw "CHECKSUM generation failed for $dir: $_" };

    return $self;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store - Base class for storage of a Pinto repository

=head1 VERSION

version 0.059

=head1 DESCRIPTION

L<Pinto::Store> is the base class for Pinto Stores.  It provides the
basic API for adding/removing distribution archives to the store.
Subclasses implement the underlying logic by augmenting the methods
declared here.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

