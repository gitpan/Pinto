# ABSTRACT: Global variables used across the Pinto utilities

package Pinto::Globals;

use strict;
use warnings;

#------------------------------------------------------------------------------

our $VERSION = '0.087'; # VERSION

#------------------------------------------------------------------------------

## no critic qw(PackageVars);
our $current_utc_time     = undef;
our $current_time_offset  = undef;
our $current_username     = undef;
our $current_author_id    = undef;
our $is_interactive       = undef;

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Karen Etheridge Michael G. Schwern Oleg
Gashev Steffen Schwigon Bergsten-Buret Wolfgang Kinkeldei Yanick Champoux
hesco Cory G Watson Jakob Voss Jeff

=head1 NAME

Pinto::Globals - Global variables used across the Pinto utilities

=head1 VERSION

version 0.087

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
