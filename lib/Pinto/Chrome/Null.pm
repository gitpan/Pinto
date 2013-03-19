# ABSTRACT: Black hole interface

package Pinto::Chrome::Null;

use Moose;
use MooseX::MarkAsMethods (autoclean => 1);

#-----------------------------------------------------------------------------

our $VERSION = '0.065_03'; # VERSION

#-----------------------------------------------------------------------------

extends qw( Pinto::Chrome );

#-----------------------------------------------------------------------------

sub show { return 1 };

#-----------------------------------------------------------------------------

sub diag { return 1 };

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Chrome::Null - Black hole interface

=head1 VERSION

version 0.065_03

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
