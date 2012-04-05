
# ABSTRACT: Report statistics about the repository
package Pinto::Action::Statistics;

use Moose;

use Pinto::Statistics;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.035'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Interface::Action::Statistics );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stats = Pinto::Statistics->new( db => $self->repos->db() );
    print { $self->out() } $stats->to_formatted_string();

    return 0;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Statistics - Report statistics about the repository

=head1 VERSION

version 0.035

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
