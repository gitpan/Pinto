# ABSTRACT: Something that makes directory paths

package Pinto::Role::PathMaker;

use Moose::Role;

use Path::Class;
use Try::Tiny;

use Pinto::Util qw(itis);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.062'; # VERSION

#------------------------------------------------------------------------------
# Roles

with qw(Pinto::Role::Loggable);

#------------------------------------------------------------------------------


sub mkpath {
    my ($self, $path) = @_;

    $path = dir($path) if not itis($path, 'Path::Class');
    throw "$path is not a Path::Class::Dir" if not $path->is_dir;
    throw "$path is an existing file" if -f $path;

    return 0 if -e $path;

    $self->debug("Making directory $path");

    try   { $path->mkpath }
    catch { throw "Failed to make directory $path: $_" };

    return 1;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::PathMaker - Something that makes directory paths

=head1 VERSION

version 0.062

=head1 METHODS

=head2 mkpath( $path )

Creates a directory at the specified path, including any intervening
directories.  Throws an exception on failure.  Returns true if a path
was actually made.  If the path already existed, returns false.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
