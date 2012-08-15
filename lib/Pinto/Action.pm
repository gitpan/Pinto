# ABSTRACT: Base class for all Actions

package Pinto::Action;

use Moose;
use MooseX::Types::Moose qw(Str);

use Pinto::Result;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.050'; # VERSION

#------------------------------------------------------------------------------

with qw( Pinto::Role::Loggable );

#------------------------------------------------------------------------------

has repos => (
    is       => 'ro',
    isa      => 'Pinto::Repository',
    required => 1,
);


has username => (
    is       => 'ro',
    isa      => Str,
    default  => sub { $ENV{USER} },
);


has result => (
    is       => 'ro',
    isa      => 'Pinto::Result',
    default  => sub { Pinto::Result->new },
    init_arg => undef,
    lazy     => 1,
);

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action - Base class for all Actions

=head1 VERSION

version 0.050

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
