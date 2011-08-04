package Pinto::Util;

# ABSTRACT: Static utility functions for Pinto

use strict;
use warnings;

use Path::Class;
use Readonly;

use base 'Exporter';

#-------------------------------------------------------------------------------

our $VERSION = '0.004'; # VERSION

#-------------------------------------------------------------------------------
# TODO: Don't export!

our @EXPORT_OK = qw(directory_for_author is_source_control_file);

#-------------------------------------------------------------------------------

Readonly my %SCM_FILES => (map {$_ => 1} qw(.svn .git .gitignore CVS));

#-------------------------------------------------------------------------------


sub directory_for_author {
    my ($author) = pop;
    my @base = @_;
    $author = uc $author;
    return dir(@base, substr($author, 0, 1), substr($author, 0, 2), $author);
}

#-------------------------------------------------------------------------------
# TODO: Is this needed?


sub index_directory_for_author {
    return directory_for_author(@_)->as_foreign('Unix');
}

#-------------------------------------------------------------------------------


sub is_source_control_file {
    my ($file) = @_;
    return exists $SCM_FILES{$file};
}

#-------------------------------------------------------------------------------


sub native_file {
    my ($file) = pop;
    my (@base) = @_;
    return file(@base, split m{/}, $file);
}

#-------------------------------------------------------------------------------


sub format_message {
    my ($header, @items) = @_;
    return "$header\n    " . join "\n    ", @items;
}

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Util - Static utility functions for Pinto

=head1 VERSION

version 0.004

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 FUNCTIONS

=head2 directory_for_author( @base, $author )

Given the name of an C<$author> returns the directory where the
archives for that author belong (as a L<Path::Class::Dir>).  The
optional C<@base> can be a series of L<Path::Class:Dir> or path parts
(as strings).  If C<@base> is given, it will be prepended to the
directory that is returned.

=head2 index_directory_for_author()

Same as C<directory_for_author()>, but returns the path as it would appear
in the F<02packages.details.txt> file.  That is, in Unix format.

=head2 is_source_control_file($path)

Given a path (which may be a file or directory), returns true if that path
is part of the internals of a source control system (e.g. git, svn, cvs).

=head2 native_file(@base, $file)

Given a Unix path to a file, returns the file in the native OS format
(as a L<Path::Class::File>);

=head2 format_message($header, @items)

Formats a commit message, consisting of a header followed by a list
of items.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

