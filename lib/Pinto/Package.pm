package Pinto::Package;

# ABSTRACT: Represents a single record in the 02packages.details.txt file

use Moose;
use MooseX::Types::Moose qw(Str);

use overload ('""' => 'to_string');

#------------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has 'name'   => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has 'version' => (
    is        => 'ro',
    isa       => Str,
    required  => 1,
);


has 'dist'    => (
    is        => 'ro',
    isa       => 'Pinto::Distribution',
    required  => 1,
);

#------------------------------------------------------------------------------


sub to_string {
    my ($self) = @_;

    return $self->name();
}

#------------------------------------------------------------------------------


sub to_index_string {
    my ($self) = @_;

    my $fw = 38 - length $self->version();
    $fw = length $self->name() if $fw < length $self->name();

    return sprintf "%-${fw}s %s  %s\n", $self->name(),
                                        $self->version(),
                                        $self->dist->location();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Package - Represents a single record in the 02packages.details.txt file

=head1 VERSION

version 0.021

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 METHODS

=head2 to_string()

Returns this Package as a string containing the package name.  This is
what you get when you evaluate and Package in double quotes.

=head2 to_index_string()

Returns this Package object as a string that is suitable for writing
to an F<02packages.details.txt> file.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

