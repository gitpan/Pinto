# ABSTRACT: Verify all distributions are present in the repository

package Pinto::Action::Verify;

use Moose;

use Pinto::Util;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_002'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Verify );

#------------------------------------------------------------------------------
# Methods

sub execute {
    my ($self) = @_;


    # FIXME!
    my $rs  = $self->repos->db->schema->resultset('Distribution')->search;

    while ( my $dist = $rs->next ) {
        my $archive = $dist->archive( $self->repos->root_dir );
        print { $self->out } "Missing distribution $archive\n" if not -e $archive;
    }

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Verify - Verify all distributions are present in the repository

=head1 VERSION

version 0.040_002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
