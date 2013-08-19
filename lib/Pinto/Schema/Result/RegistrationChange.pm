# ABSTRACT: Not in use -- will be removed

package Pinto::Schema::Result::RegistrationChange;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

#-----------------------------------------------------------------------------

our $VERSION = '0.089'; # VERSION

#-----------------------------------------------------------------------------

__PACKAGE__->table("registration_change");

#-----------------------------------------------------------------------------

1;

__END__

=pod

=encoding utf-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Voss Jeff Karen Etheridge Michael G.
Schwern Bergsten-Buret Oleg Gashev Steffen Schwigon Tommy Stanton Wolfgang
Kinkeldei Yanick Champoux Boris hesco popl Däppen Cory G Watson Glenn
Fowler Jakob

=head1 NAME

Pinto::Schema::Result::RegistrationChange - Not in use -- will be removed

=head1 VERSION

version 0.089

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
