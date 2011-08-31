package Pinto::Util;

# ABSTRACT: Static utility functions for Pinto

use strict;
use warnings;

use Path::Class;
use Readonly;

use namespace::autoclean;

#-------------------------------------------------------------------------------

our $VERSION = '0.023'; # VERSION

#-------------------------------------------------------------------------------

Readonly my %SCM_FILES => (map {$_ => 1} qw(.svn .git .gitignore CVS));

#-------------------------------------------------------------------------------


sub author_dir {                                  ## no critic (ArgUnpacking)
    my $author = uc pop;
    my @base =  @_;

    return dir(@base, substr($author, 0, 1), substr($author, 0, 2), $author);
}

#-------------------------------------------------------------------------------


sub is_source_control_file {
    my ($file) = @_;
    return exists $SCM_FILES{$file};
}

#-------------------------------------------------------------------------------

sub added_dist_message {
    my ($distribution) = @_;
    return _dist_message($distribution, 'Added');
}

#-------------------------------------------------------------------------------

sub removed_dist_message {
    my ($distribution) = @_;
    return _dist_message($distribution, 'Removed');
}

#-------------------------------------------------------------------------------

sub _dist_message {
    my ($dist, $action) = @_;
    my @packages = @{ $dist->packages() };
    my @items = sort map { $_->name() . ' ' . $_->version() } @packages;
    return "$action distribution $dist providing:\n    " . join "\n    ", @items;
}

#-------------------------------------------------------------------------------

sub args_from_fh {
    my ($fh) = @_;

    my @args;
    while (my $line = <$fh>) {
        chomp $line;
        next if not length $line;
        next if $line =~ m/^ \s* [;#]/x;
        next if $line !~ m/\S/x;
        push @args, $line;
    }

    return @args;
}

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Util - Static utility functions for Pinto

=head1 VERSION

version 0.023

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 FUNCTIONS

=head2 author_dir( @base, $author )

Given the name of an C<$author>, returns the directory where the
distributions for that author belong (as a L<Path::Class::Dir>).  The
optional C<@base> can be a series of L<Path::Class:Dir> or path parts
(as strings).  If C<@base> is given, it will be prepended to the
directory that is returned.

=head2 is_source_control_file($path)

Given a path (which may be a file or directory), returns true if that path
is part of the internals of a version control system (e.g. Git, Subversion).

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

