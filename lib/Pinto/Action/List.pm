package Pinto::Action::List;

# ABSTRACT: An action for listing contents of a repository

use Moose;

use Carp qw(croak);

use MooseX::Types::Moose qw(Str HashRef);
use Pinto::Types qw(IO);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.033'; # VERSION

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


has where => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $where = $self->where();

    my $attrs = { order_by => [ qw(name version path) ],
                  prefetch => 'distribution' };

    my $rs = $self->repos->db->select_packages($where, $attrs);

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

Pinto::Action::List - An action for listing contents of a repository

=head1 VERSION

version 0.033

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
