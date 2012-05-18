# ABSTRACT: Something that operates on the repository

package Pinto::Role::Operator;

use Moose::Role;
use MooseX::Types::Moose qw(Bool);

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.042'; # VERSION

#-----------------------------------------------------------------------------

requires qw(operative_stack);

#-----------------------------------------------------------------------------

has dryrun => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Operator - Something that operates on the repository

=head1 VERSION

version 0.042

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
