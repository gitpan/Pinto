# ABSTRACT: Common queries for Distributions

use utf8;
package Pinto::Schema::ResultSet::Distribution;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

#------------------------------------------------------------------------------

our $VERSION = '0.082'; # VERSION

#------------------------------------------------------------------------------

sub with_packages {
  my ($self, $where) = @_;

  return $self->search($where || {}, {prefetch => 'packages'});
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

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Schema::ResultSet::Distribution - Common queries for Distributions

=head1 VERSION

version 0.082

=head1 CONTRIBUTORS

=over 4

=item *

Cory G Watson <gphat@onemogin.com>

=item *

Jakob Voss <jakob@nichtich.de>

=item *

Jeff <jeff@callahan.local>

=item *

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=item *

Jeffrey Thalhammer <jeff@imaginative-software.com>

=item *

Karen Etheridge <ether@cpan.org>

=item *

Michael G. Schwern <schwern@pobox.com>

=item *

Steffen Schwigon <ss5@renormalist.net>

=item *

Wolfgang Kinkeldei <wolfgang@kinkeldei.de>

=item *

Yanick Champoux <yanick@babyl.dyndns.org>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
