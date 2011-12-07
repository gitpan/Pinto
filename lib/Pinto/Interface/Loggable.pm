package Pinto::Interface::Loggable;

# ABSTRACT: Something that wants to log its activity

use Moose::Role;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.026'; # VERSION

#-----------------------------------------------------------------------------

has logger => (
    is         => 'ro',
    isa        => 'Pinto::Logger',
    handles    => [ qw(debug note info whine fatal) ],
    required   => 1,
);

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Interface::Loggable - Something that wants to log its activity

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