# ABSTRACT: Common queries for Registrations

use utf8;

package Pinto::Schema::ResultSet::Registration;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

#------------------------------------------------------------------------------

our $VERSION = '0.0995'; # VERSION

#------------------------------------------------------------------------------

sub with_package {
    my ( $self, $where ) = @_;

    return $self->search( $where || {}, { prefetch => 'package' } );
}

#------------------------------------------------------------------------------

sub with_distribution {
    my ( $self, $where ) = @_;

    return $self->search( $where || {}, { prefetch => 'distribution' } );
}

#------------------------------------------------------------------------------

sub with_revision {
    my ( $self, $where ) = @_;

    return $self->search( $where || {}, { revision => 'distribution' } );
}

#------------------------------------------------------------------------------

sub as_hash {
    my ( $self, $cb ) = @_;

    $cb ||= sub { return ( $_[0]->id => $_[0] ) };
    my %hash = map { $cb->($_) } $self->all;

    return wantarray ? %hash : \%hash;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux brian d foy hesco popl Däppen Cory
G Watson David Steinbrunner Glenn

=head1 NAME

Pinto::Schema::ResultSet::Registration - Common queries for Registrations

=head1 VERSION

version 0.0995

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
