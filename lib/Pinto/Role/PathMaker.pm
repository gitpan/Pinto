package Pinto::Role::PathMaker;

# ABSTRACT: Something that makes directory paths

use Moose::Role;

use Carp;
use Path::Class;
use English qw(-no_match_vars);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.011'; # VERSION

#------------------------------------------------------------------------------
# Required attributes

requires 'logger';

#------------------------------------------------------------------------------


sub mkpath {
    my ($self, $path) = @_;

    $path = dir($path) if not eval {$path->isa('Path::Class')};

    croak "$path is not a Path::Class::Dir" if not $path->is_dir();
    croak "$path is an existing file" if -f $path;

    return 0 if -e $path;

    $self->logger->debug("Making directory $path");

    eval { $path->mkpath(); 1}
        or croak "Failed to make directory $path: $EVAL_ERROR";

    return 1;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::PathMaker - Something that makes directory paths

=head1 VERSION

version 0.011

=head1 METHODS

=head2 mkpath( $path )

Creates a directory at the specified path, including any intervening
directories.  Croaks on failure.  Returns true if a path was actually
made.  If the path already existed, returns false.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
