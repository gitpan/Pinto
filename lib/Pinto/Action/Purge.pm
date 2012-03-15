package Pinto::Action::Purge;

# ABSTRACT: Remove all distributions from the repository

use Moose;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.033'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $dists = $self->repos->db->select_distributions();

    my $count = $dists->count();
    $self->info("Removing all $count distributions from the repository");

    my $removed = 0;
    while ( my $dist = $dists->next() ) {
        $self->repos->remove_distribution($dist);
        $removed++
    }

    $self->add_message("Purged all $removed distributions" ) if $removed;

    return $removed;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Purge - Remove all distributions from the repository

=head1 VERSION

version 0.033

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
