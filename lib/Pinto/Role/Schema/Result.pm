# ABSTRACT: Attributes and methods for all Schema::Result objects

package Pinto::Role::Schema::Result;

use Moose::Role;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.047'; # VERSION

#------------------------------------------------------------------------------

has logger  => (
   handles  => [ qw(debug info notice warning error fatal) ],
   default  => sub { $_[0]->result_source->schema->logger },
   init_arg => undef,
   lazy     => 1,
);

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Schema::Result - Attributes and methods for all Schema::Result objects

=head1 VERSION

version 0.047

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
