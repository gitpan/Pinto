package Pinto::Action::List;

# ABSTRACT: An abstract action for listing packages in a repository

use Moose;

use Carp qw(croak);

use MooseX::Types::Moose qw(Bool Str);
use Pinto::Types qw(IO);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.026'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has out => (
    is      => 'ro',
    isa     => IO,
    coerce  => 1,
    default => sub { [fileno(STDOUT), '>'] },
);


has format => (
    is      => 'ro',
    isa     => Str,
    default => '',
);

#------------------------------------------------------------------------------

sub package_rs {
    my ($self) = @_;

    my $attrs = { order_by => [ qw(name version path) ],
                  prefetch => 'distribution' };

    return $self->repos->db->select_packages(undef, $attrs);
}

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $rs = $self->package_rs();
    my $format = $self->format();
    while( my $package = $rs->next() ) {
        print { $self->out() } $package->to_formatted_string($format);
    }

    return 0;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::List - An abstract action for listing packages in a repository

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
