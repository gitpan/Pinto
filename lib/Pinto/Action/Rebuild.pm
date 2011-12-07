package Pinto::Action::Rebuild;

# ABSTRACT: Rebuild the index file for the repository

use Moose;

use MooseX::Types::Moose qw(Bool);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.026'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has recompute => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    $self->_recompute() if $self->recompute();

    $self->add_message('Rebuilt the index');

    return 1;
}

#------------------------------------------------------------------------------

sub _recompute {
    my ($self) = @_;

    # Gotta be a better way to to do this...
    my $attrs  = {select => ['name'], distinct => 1};
    my $cursor = $self->repos->select_packages(undef, $attrs)->cursor();

    while (my ($name) = $cursor->next()) {
        my $rs  = $self->repos->select_packages( {name => $name} );
        next if $rs->count() == 1;  # Only need to recompute if more than 1
        $self->debug("Recomputing latest version of package $name");
        $self->repos->db->mark_latest( $rs->first() );
    }

    $self->add_message('Recalculated the latest version of all packages');

    return $self;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Rebuild - Rebuild the index file for the repository

=head1 VERSION

version 0.026

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
