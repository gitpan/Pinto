# ABSTRACT: Base class for Pinto exceptions

package Pinto::Exception;

use Moose;
use Moose::Exporter;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

extends 'Throwable::Error';

#------------------------------------------------------------------------------

Moose::Exporter->setup_import_methods( as_is => [ throw => \&throw ] );

#------------------------------------------------------------------------------
# HACK: I'm not sure this will work with subclasses

sub throw { __PACKAGE__->SUPER::throw(@_) }

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Exception - Base class for Pinto exceptions

=head1 VERSION

version 0.040_001

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
