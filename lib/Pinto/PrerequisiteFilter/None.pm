# ABSTRACT: Filters nothing

package Pinto::PrerequisiteFilter::None;

use Moose;
use MooseX::MarkAsMethods (autoclean => 1);

#------------------------------------------------------------------------------

our $VERSION = '0.065_01'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::PrerequisiteFilter );

#------------------------------------------------------------------------------

sub should_filter {
    my ($self, $prereq) = @_;

    return 0;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::PrerequisiteFilter::None - Filters nothing

=head1 VERSION

version 0.065_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
