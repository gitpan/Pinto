# ABSTRACT: Role for actions that are transactional

package Pinto::Role::Transactional;

use Moose::Role;
use MooseX::MarkAsMethods ( autoclean => 1 );

use Try::Tiny;

use Pinto::Util qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.087_05'; # VERSION

#------------------------------------------------------------------------------

requires qw( execute repo );

#------------------------------------------------------------------------------

around execute => sub {
    my ( $orig, $self, @args ) = @_;

    $self->repo->txn_begin;

    my $result = try { $self->$orig(@args); $self->repo->txn_commit } catch { $self->repo->txn_rollback; throw $_ };

    return $self->result;
};

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Voss Jeff Karen Etheridge Michael G.
Schwern Bergsten-Buret Oleg Gashev Steffen Schwigon Wolfgang Kinkeldei
Yanick Champoux hesco Boris D�ppen Cory G Watson Glenn Fowler Jakob

=head1 NAME

Pinto::Role::Transactional - Role for actions that are transactional

=head1 VERSION

version 0.087_05

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
