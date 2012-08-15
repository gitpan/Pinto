# ABSTRACT: Something that wants to log its activity

package Pinto::Role::Loggable;

use Moose::Role;

use Pinto::Logger;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.048'; # VERSION

#-----------------------------------------------------------------------------

has logger => (
    is         => 'ro',
    isa        => 'Pinto::Logger',
    handles    => [ qw(debug info notice warning error fatal) ],
    required   => 1,
);

#-----------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $args = $class->$orig(@_);

    $args->{logger} = Pinto::Logger->new( %$args ) if not exists $args->{logger};
    return $args;
};

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Loggable - Something that wants to log its activity

=head1 VERSION

version 0.048

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
