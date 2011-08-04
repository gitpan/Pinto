package Pinto::Action::Create;

# ABSTRACT: An action to create a new repository

use Moose;

use Carp;
use Path::Class;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.003'; # VERSION

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    # Someone could use the <create> action to pull an existing repository
    # out of VCS to a new location on the file system.  So if the
    # master index file already exists, then assume that the repository
    # has already been created and return false to indicate that
    # no commits are required.

    my $local = Path::Class::dir( $self->config()->local() );
    return 0 if -e file($local, qw(modules 02packages.details.txt.gz));

    # Otherwise, let Pinto create the directories and index files
    # for us, and return true to indicate that a commit is required.

    $self->_set_message('Created a new Pinto repository');
    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Create - An action to create a new repository

=head1 VERSION

version 0.003

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
