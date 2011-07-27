package Pinto::Package;

# ABSTRACT: Represents a single record in the 02packages.details.txt file

use Moose;
use Path::Class::File;

#------------------------------------------------------------------------------

our $VERSION = '0.002'; # VERSION

#------------------------------------------------------------------------------


has 'name'   => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);


has 'version' => (
    is        => 'ro',
    isa       => 'Str',
    required  => 1,
);


has 'file'    => (
    is        => 'ro',
    isa       => 'Str',
    required  => 1,
);


has 'author'  => (
    is        => 'ro',
    isa       => 'Str',
    lazy      => 1,
    init_arg  => undef,
    default   => sub { $_[0]->native_file()->dir()->dir_list(2, 1) },
);

#------------------------------------------------------------------------------

# TODO: Declare subtype for the 'file' attribute and coerce it from a
# Path::Class::File to a string that always looks like a Unix path.

#------------------------------------------------------------------------------


sub to_string {
    my ($self) = @_;
    my $fw = 38 - length $self->version();
    $fw = length $self->name() if $fw < length $self->name();
    return sprintf "%-${fw}s %s  %s", $self->name(), $self->version(), $self->file();
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Package - Represents a single record in the 02packages.details.txt file

=head1 VERSION

version 0.002

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 ATTRIBUTES

=head2 name()

Returns the name of this Package as a string.  For example, C<Foo::Bar>.

=head2 version()

Returns the version of this Package as a string.  This could be a number
or some "version string", such as C<1.5.23>.

=head2 file()

Returns the path to the file this Package lives in, as a string.  The path
is as it appears in the C<02packages.details.txt> file.  So it will be
in Unix format and relative to the F<authors/id> directory.

=head2 native_file()

Same as the C<file()> method, but returns the path as a
L<Path::Class::File> object that is suitable for your OS.

has 'native_file' => (
    is            => 'ro',
    isa           => 'Path::Class::File',
    lazy          => 1,
    init_arg      => undef,
    default       => sub { Path::Class::File->new( $_[0]->file() ) },
);

=head2 author()

Returns the author of this Package.  The author is extracted from the
path to the file this Package lives in.  For example, the author of
F<J/JO/JOHN/Foo-Bar-1.2.tar.gz> will be C<JOHN>.

=head1 METHODS

=head2 to_string()

Returns this Package object in a format that is suitable for writing
to an F<02packages.details.txt> file.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

