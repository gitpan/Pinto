package Pinto::Store;

# ABSTRACT: Back-end storage for a Pinto repoistory

use Moose;

#------------------------------------------------------------------------------

our $VERSION = '0.004'; # VERSION

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
        $self->logger->log("Making directory at $local ... ", {nolf => 1});
        $local->mkpath(); # TODO: Set dirmode and verbosity here.
        $self->logger->log("DONE");
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
    # TODO: Default implementation - delete empty directories?
    return 1;
}


#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store - Back-end storage for a Pinto repoistory

=head1 VERSION

version 0.004

=head1 DESCRIPTION

L<Pinto::Store> util is the default back-end for a Pinto repository.
It basically just represents files on disk.  You should look at
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

