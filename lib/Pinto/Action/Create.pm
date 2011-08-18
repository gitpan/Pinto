package Pinto::Action::Create;

# ABSTRACT: An action to create a new repository

use Moose;

use Carp;
use Path::Class;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.015'; # VERSION

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    # This is a terrible hack.  We are relying on Pinto::Index
    # to create the files for us.

    my $master_index_file = $self->idxmgr->master_index->write->file();
    my $local_index_file  = $self->idxmgr->local_index->write->file();

    $self->store->add( file => $master_index_file );
    $self->store->add( file => $local_index_file );

    $self->add_message('Created a new Pinto repository');
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

version 0.015

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
