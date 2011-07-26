package Pinto::Store;

# ABSTRACT: Back-end storage for a Pinto repoistory

use Moose;
use Path::Class;

#---------------------------------------------------------------------------------------

our $VERSION = '0.001'; # VERSION

#---------------------------------------------------------------------------------------


has config => (
    is       => 'ro',
    isa      => 'Pinto::Config',
    required => 1,
);

#---------------------------------------------------------------------------------------


sub initialize {
    my ($self, %args) = @_;

    my $local = $args{local} || $self->config()->get_required('local');
    Path::Class::dir($local)->mkpath();

    return 1;
}

#---------------------------------------------------------------------------------------


sub finalize {
    my ($self, %args) = @_;

    return 1;
}


#---------------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store - Back-end storage for a Pinto repoistory

=head1 VERSION

version 0.001

=head1 DESCRIPTION

L<Pinto::Store> util is the default back-end for a Pinto repository.
It basically just represents files on disk.  You should look at
L<Pinto::Store::Svn> or L<Pinto::Store::Git> for a more interesting
example.

=head1 ATTRIBUTES

=head2 config()

Returns the L<Pinto::Config> object for this Store.  This must be
provided through the constructor and should be the same
L<Pinto::Config> that L<Pinto> has.

=head1 METHODS

=head2 initialize()

This method is called before each Pinto action, and is responsible for
doing any setup work that is required by the Store.  This could
include making a directory on the file system, checking out some
directory from an SCM repository, or cloning an SCM repository.  If
the initialization fails, an exception should be thrown.

=head2 finalize(message => 'what happened')

This method is called after each Pinto action and is responsible for
doing any work that is required to commit the Store.  This could
include committing changes, pushing commits to a remote repository,
and/or making a tag.  If the finalization fails, an exception should
be thrown.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

