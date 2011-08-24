package Pinto::Exception;

# ABSTRACT: Base class for Pinto exceptions

use strict;
use warnings;

#-----------------------------------------------------------------------------

our $VERSION = '0.019'; # VERSION

#-----------------------------------------------------------------------------

use Exception::Class ( 'Pinto::Exception' => {isa  => 'Exception::Class::Base'} );

use base 'Exporter';

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Exception - Base class for Pinto exceptions

=head1 VERSION

version 0.019

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
