package Pinto::Tester::Util;

# ABSTRACT: Static helper functions for testing

use strict;
use warnings;

use Pinto::Schema;

use base 'Exporter';

#-------------------------------------------------------------------------------

our $VERSION = '0.026'; # VERSION

#-------------------------------------------------------------------------------

our @EXPORT_OK = qw( make_dist make_pkg );

#-------------------------------------------------------------------------------

sub make_pkg {
    my %attrs = @_;
    return Pinto::Schema->resultset('Package')->new_result( \%attrs );
}

#------------------------------------------------------------------------------

sub make_dist {
    my %attrs = @_;
    return Pinto::Schema->resultset('Distribution')->new_result( \%attrs );
}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Tester::Util - Static helper functions for testing

=head1 VERSION

version 0.026

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
