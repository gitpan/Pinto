# ABSTRACT: Role for actions that are transactional

package Pinto::Role::Transactional;

use Moose::Role;
use MooseX::MarkAsMethods (autoclean => 1);

use Try::Tiny;

#------------------------------------------------------------------------------

our $VERSION = '0.065_02'; # VERSION

#------------------------------------------------------------------------------

requires qw( execute repo );

#------------------------------------------------------------------------------

around execute => sub {
    my ($orig, $self, @args) = @_;

    $self->repo->txn_begin;

    my $result = try   { $self->$orig(@args); $self->repo->txn_commit }
                 catch { $self->repo->txn_rollback; die $_            };

    return $self->result;
};

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Transactional - Role for actions that are transactional

=head1 VERSION

version 0.065_02

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
