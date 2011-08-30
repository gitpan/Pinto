package Pinto::Exception::IO;

# ABSTRACT: Exception class used by Pinto

use strict;
use warnings;

#-----------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#-----------------------------------------------------------------------------

use Exception::Class (

      'Pinto::Exception::IO' => { isa   => 'Pinto::Exception',
                                  alias => 'throw_io' },
);

use Readonly;
Readonly our @EXPORT_OK => qw(throw_io);

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Exception::IO - Exception class used by Pinto

=head1 VERSION

version 0.021

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
