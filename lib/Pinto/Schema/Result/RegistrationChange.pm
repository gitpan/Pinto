# ABSTRACT: Not in use -- will be removed

package Pinto::Schema::Result::RegistrationChange;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

#-----------------------------------------------------------------------------

our $VERSION = '0.084_01'; # VERSION

#-----------------------------------------------------------------------------

__PACKAGE__->table("registration_change");

#-----------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Karen Etheridge Michael G. Schwern Oleg
Gashev Steffen Schwigon Bergsten-Buret Wolfgang Kinkeldei Yanick Champoux
hesco Cory G Watson Jakob Voss Jeff

=head1 NAME

Pinto::Schema::Result::RegistrationChange - Not in use -- will be removed

=head1 VERSION

version 0.084_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut