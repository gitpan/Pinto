package Pinto::Role::Configurable;

# ABSTRACT: Something that has a configuration

use Moose::Role;

use Pinto::Config;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.052'; # VERSION

#-----------------------------------------------------------------------------

has config => (
    is         => 'ro',
    isa        => 'Pinto::Config',
    handles    => [ qw( root root_dir ) ],
    required   => 1,
);

#-----------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $args = $class->$orig(@_);

    $args->{config} ||= Pinto::Config->new( $args );
    return $args;
};

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Configurable - Something that has a configuration

=head1 VERSION

version 0.052

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
