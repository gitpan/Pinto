package Pinto::Store::File;

# ABSTRACT: Store a Pinto repository on the local filesystem

use Moose;

use Pinto::Exceptions qw(throw_fatal);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.038'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends qw( Pinto::Store );

#------------------------------------------------------------------------------
# Methods

augment remove_path => sub {
    my ($self, %args) = @_;

    my $path = $args{path};
    $path->remove() or throw_fatal "Failed to remove path $path: $!";

    while (my $dir = $path->parent()) {
        last if $dir->children();
        $self->debug("Removing empty directory $dir");
        $dir->remove() or throw_fatal "Failed to remove directory $dir: $!";
        $path = $dir;
    }

    return $self;
};

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store::File - Store a Pinto repository on the local filesystem

=head1 VERSION

version 0.038

=head1 DESCRIPTION

L<Pinto::Store::File> is the default back-end for a Pinto repository.
It basically just represents files on disk.  You should look at
L<Pinto::Store::VCS::Svn> or L<Pinto::Store::VCS::Git> for a more
interesting example.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

