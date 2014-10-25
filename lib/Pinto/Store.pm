package Pinto::Store;

# ABSTRACT: Back-end storage for a Pinto repoistory

use Moose;

use Carp;
use File::Copy;

#------------------------------------------------------------------------------

our $VERSION = '0.008'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has added_paths => (
    is          => 'ro',
    isa         => 'ArrayRef[Path::Class]',
    init_arg    => undef,
    default     => sub { [] },
);

has removed_paths => (
    is          => 'ro',
    isa         => 'ArrayRef[Path::Class]',
    init_arg    => undef,
    default     => sub { [] },
);

has modified_paths => (
    is          => 'ro',
    isa         => 'ArrayRef[Path::Class]',
    init_arg    => undef,
    default     => sub { [] },
);

#------------------------------------------------------------------------------
# Moose roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------
# Methods


sub initialize {
    my ($self) = @_;

    my $local = $self->config->local();

    if (not -e $local) {
        $self->logger->log("Making directory at $local");
        eval { $local->mkpath(); 1 }
            or croak "Failed to make directory $local: $@";
    }

    return 1;
}

#------------------------------------------------------------------------------


sub is_initialized {
    my ($self) = @_;

    return -e $self->config->local();
}

#------------------------------------------------------------------------------


sub finalize {
    my ($self, %args) = @_;
    return 1;
}


#------------------------------------------------------------------------------

sub add {
    my ($self, %args) = @_;

    my $file   = $args{file};
    my $source = $args{source};

    croak "$file does not exist and no source was specified"
        if not -e $file and not defined $source;

    croak "$source is not a file"
        if $source and $source->is_dir();

    if ($source) {

        if ( not -e (my $parent = $file->parent()) ) {
            $self->logger->debug("Making directory at $parent");
            eval { $parent->mkpath(); 1 }
                or croak "Failed to make directory $parent: $@";
        }

        $self->logger->debug("Copying $source to $file");
        File::Copy::copy($source, $file) or croak "Failed to copy $source to $file: $!";
    }

    return $self;
}

#------------------------------------------------------------------------------

sub remove {
    my ($self, %args) = @_;

    my $path  = $args{file};
    my $prune = $args{prune};

    return $self if not -e $path;
    croak "$path is not a file" if $path->is_dir();

    $self->logger->log("Removing file $path");
    $path->remove() or croak "Failed to remove $path: $!";

    if ($prune) {
        while (my $dir = $path->dir()) {
            last if $dir->children();
            $self->logger->debug("Removing empty directory $dir");
            $dir->remove();
            $path = $dir;
         }
    }

    return $self;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store - Back-end storage for a Pinto repoistory

=head1 VERSION

version 0.008

=head1 DESCRIPTION

L<Pinto::Store> is the default back-end for a Pinto repository.  It
basically just represents files on disk.  You should look at
L<Pinto::Store::Svn> or L<Pinto::Store::Git> for a more interesting
example.

=head1 METHODS

=head2 initialize()

This method is called before each batch of Pinto events, and is
responsible for doing any setup work that is required by the Store.
This could include making a directory on the file system, checking out
or updating a working copy, cloning, or pulling commits.  If the
initialization fails, an exception should be thrown.

The default implementation simply creates a directory.

=head2 is_initialized()

Returns true if the store appears to be initialized.  In this base class,
it simply means that the working directory exists.  For other subclasses,
this could mean that the working copy is up-to-date.

=head2 finalize(message => 'what happened')

This method is called after each batch of Pinto events and is
responsible for doing any work that is required to commit the Store.
This could include scheduling files for addition/deletion, pushing
commits to a remote repository, and/or making a tag.  If the
finalization fails, an exception should be thrown.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

