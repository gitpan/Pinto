# ABSTRACT: Common queries for Packages

use utf8;
package Pinto::Schema::ResultSet::Package;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

#------------------------------------------------------------------------------

our $VERSION = '0.065_01'; # VERSION

#------------------------------------------------------------------------------

sub with_distribution {
  my ($self, $where) = @_;

  return $self->search($where || {}, {prefetch => 'distribution'});
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::ResultSet::Package - Common queries for Packages

=head1 VERSION

version 0.065_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
