package Pinto::Util;

# ABSTRACT: Static utility functions for Pinto

use strict;
use warnings;
use version;

use Carp;
use Try::Tiny;
use Path::Class;
use Digest::MD5;
use Digest::SHA;
use DateTime;
use Readonly;

use Pinto::Exception qw(throw);

use namespace::autoclean;

#-------------------------------------------------------------------------------

our $VERSION = '0.051'; # VERSION

#-------------------------------------------------------------------------------


sub author_dir {                                  ## no critic (ArgUnpacking)
    my $author = uc pop;
    my @base =  @_;

    return dir(@base, substr($author, 0, 1), substr($author, 0, 2), $author);
}

#-------------------------------------------------------------------------------

sub parse_dist_url {
    my ($url) = @_;

    #  $path = '/yadda/yadda/authors/id/A/AU/AUTHOR/Foo-1.2.tar.gz'
    my $path = $url->path();

    if ( $path =~ s{^ (.*) /authors/id/(.*) $}{$2}mx ) {

        # $path = 'A/AU/AUTHOR/Foo-1.2.tar.gz'
        my $source     = $url->isa('URI::file') ? $1 : $url->authority();
        my @path_parts = split m{ / }mx, $path; # qw( A AU AUTHOR Foo-1.2.tar.gz )
        my $author     = $path_parts[2];
        return ($source, $path, $author);
    }
    else {

        confess 'Unable to parse url: $url';
    }

}

#-------------------------------------------------------------------------------

sub isa_perl {
    my ($path_or_url) = @_;

    return $path_or_url =~ m{ / perl-[\d.]+ \.tar \.gz $ }mx;
}

#-------------------------------------------------------------------------------

Readonly my %VCS_FILES => (map {$_ => 1} qw(.svn .git .gitignore CVS));

sub is_vcs_file {
    my ($file) = @_;

    $file = file($file) unless eval { $file->isa('Path::Class::File') };

    return exists $VCS_FILES{ $file->basename() };
}

#-------------------------------------------------------------------------------

sub mtime {
    my ($file) = @_;

    confess 'Must supply a file' if not $file;
    confess "$file does not exist" if not -e $file;

    return (stat $file)[9];
}

#-------------------------------------------------------------------------------

sub md5 {
    my ($file) = @_;

    confess 'Must supply a file' if not $file;
    confess "$file does not exist" if not -e $file;

    my $fh = $file->openr();
    my $md5 = Digest::MD5->new->addfile($fh)->hexdigest();

    return $md5;
}

#-------------------------------------------------------------------------------

sub sha256 {
    my ($file) = @_;

    confess 'Must supply a file' if not $file;
    confess "$file does not exist" if not -e $file;

    my $fh = $file->openr();
    my $sha256 = Digest::SHA->new(256)->addfile($fh)->hexdigest();

    return $sha256;
}

#-------------------------------------------------------------------------------


sub normalize_property_name {
    my ($prop_name) = @_;

    $prop_name = lc  $prop_name;
    throw "Invalid property name $prop_name" if $prop_name =~ m{[^a-z0-9._:-]};

    return $prop_name;
}

#-------------------------------------------------------------------------------


sub normalize_stack_name {
    my ($stack_name) = @_;

    $stack_name = lc  $stack_name;
    throw "Invalid stack name $stack_name" if $stack_name =~ m{[^a-z0-9._:-]};

    return $stack_name;
}

#-------------------------------------------------------------------------------



sub ls_time_format {
    my ($time) = @_;
    my $now = time;
    my $diff = $now - $time;
    my $one_year = 60 * 60 * 24 * 365;  # seconds per year

    my $format = $diff > $one_year ? '%b %e  %Y' : '%b %e %H:%M';
    return DateTime->from_epoch( time_zone => 'local', epoch => $time )->strftime($format);
}

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Util - Static utility functions for Pinto

=head1 VERSION

version 0.051

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

=head2 normalize_property_name( $prop_name )

Normalizes the property name and returns it.  Throws an exception if
the property name is invalid.  Currently, property names must be
alphanumeric plus any of C<m/[._:-]/>.

=head2 normalize_stack_name( $stack_name )

Normalizes the stack name and returns it.  Throws an exception if the
stack name is invalid.  Currently, stack names must be alphanumeric
plus any of C<m/[._:-]/>.

=head2 ls_time_format( $seconds_since_epoch )

Formats a time value into a string that is similar to what you see in
the output from the C<ls -l> command.  If the given time is less than
1 year ago from now, you'll see the month, day, and time.  If the time
is more than 1 year ago, you'll see the month, day, and year.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

