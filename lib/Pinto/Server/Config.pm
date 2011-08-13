package Pinto::Server::Config;

# ABSTRACT: Configuration for Pinto::Server

use Moose;
use MooseX::Types::Moose qw(Int);

use namespace::autoclean;

extends 'Pinto::Config';

#------------------------------------------------------------------------------

our $VERSION = '0.009'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has 'port'   => (
    is        => 'ro',
    isa       => Int,
    key       => 'port',
    section   => 'Pinto::Server',
    default   => 1973,
);

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Server::Config - Configuration for Pinto::Server

=head1 VERSION

version 0.009

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

