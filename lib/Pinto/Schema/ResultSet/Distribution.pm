# ABSTRACT: Common queries for Distributions

use utf8;
package Pinto::Schema::ResultSet::Distribution;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

#------------------------------------------------------------------------------

our $VERSION = '0.065_03'; # VERSION

#------------------------------------------------------------------------------

sub with_packages {
  my ($self, $where) = @_;

  return $self->search($where || {}, {prefetch => 'packages'});
}

#------------------------------------------------------------------------------

sub find_by_sha256 {
  my ($self, $sha256) = @_;

  return $self->find({sha256 => $sha256}, {key => 'sha256_unique'});
}

#------------------------------------------------------------------------------

sub find_by_md5 {
  my ($self, $md5) = @_;

  return $self->find({md5 => $md5}, {key => 'md5_unique'});
}

#------------------------------------------------------------------------------

sub find_by_author_archive {
  my ($self, $author, $archive) = @_;

  my $where = {author => $author, archive => $archive};
  my $attrs = {key => 'author_archive_unique'};

  return $self->find($where, $attrs);
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::ResultSet::Distribution - Common queries for Distributions

=head1 VERSION

version 0.065_03

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
