# ABSTRACT: report statistics about the repository

package App::Pinto::Command::statistics;

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.084_02'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw( statistics stats ) }

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Karen Etheridge Michael G. Schwern Oleg
Gashev Steffen Schwigon Bergsten-Buret Wolfgang Kinkeldei Yanick Champoux
hesco Cory G Watson Jakob Voss Jeff

=head1 NAME

App::Pinto::Command::statistics - report statistics about the repository

=head1 VERSION

version 0.084_02

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT statistics

=head1 DESCRIPTION

!! THIS COMMAND IS EXPERIMENTAL !!

This command reports some statistics about the repository.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

None.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
