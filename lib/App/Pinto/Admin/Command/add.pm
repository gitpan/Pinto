package App::Pinto::Admin::Command::add;

# ABSTRACT: add local distributions to the repository

use strict;
use warnings;

use Pinto::Util;

#------------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub command_names { return qw( add inject ) }

#-----------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'author=s'    => 'Your (alphanumeric) author ID' ],
        [ 'norecurse'   => 'Do not recursively import prereqs' ],
        [ 'pin'         => 'Pin packages to the stack' ],
        [ 'stack|s=s'   => 'Put packages into this stack' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --root=PATH $command [OPTIONS] ARCHIVE_FILE ...
%c --root=PATH $command [OPTIONS] < LIST_OF_ARCHIVE_FILES
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub args_attribute { return 'archives' }

#------------------------------------------------------------------------------

sub args_from_stdin { return 1 }

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::add - add local distributions to the repository

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir add [OPTIONS] ARCHIVE_FILE ...
  pinto-admin --root=/some/dir add [OPTIONS] < LIST_OF_ARCHIVE_FILES

=head1 DESCRIPTION

This command adds local distribution archives to the repository.
Then it recursively locates and pulls all the distributions that are
necessary to satisfy their prerequisites.

When locating packages, Pinto first looks at the the packages that
already exist in the local repository, then Pinto looks at the
packages that are available available on the upstream repositories.

=head1 COMMAND ARGUMENTS

Arguments to this command are paths to the distribution archives that
you wish to add.  Each of these files must exist and must be readable.

You can also pipe arguments to this command over STDIN.  In that case,
blank lines and lines that look like comments (i.e. starting with "#"
or ';') will be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --author=NAME

Set the identity of the distribution author.  The C<NAME> must be
alphanumeric characters (no spaces) and will be forced to uppercase.
Defaults to the C<user> specified in your C<~/.pause> configuration
file (if such file exists).  Otherwise, defaults to your current login
username.

=item --norecurse

Do not recursively pull distributions required to satisfy the
prerequisites of the added distributions.

=item --pin

Pins all the packages in the added distributions to the stack, so they
cannot be changed until you unpin them.  The pin does not apply to any
prerequisites that are pulled in for this distribution.  However, you
may pin them separately with the C<pin> command, if you so desire.

=item --stack=NAME

Places all the packages within the distribution into the stack with
the given NAME.  Otherwise, packages go onto the 'default' stack.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

