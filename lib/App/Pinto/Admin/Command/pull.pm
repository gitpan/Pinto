# ABSTRACT: pull distributions from upstream repositories

package App::Pinto::Admin::Command::pull;

use strict;
use warnings;

use Pinto::Util;

#------------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub command_names { return qw( pull ) }

#-----------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'norecurse'   => 'Do not recursively pull prereqs'   ],
        [ 'pin'         => 'Pin all the packages to the stack' ],
        [ 'stack|s=s'   => 'Put packages into this stack'      ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --root=PATH $command [OPTIONS] TARGET ...
%c --root=PATH $command [OPTIONS] < LIST_OF_TARGETS
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub args_attribute { return 'targets' }

#------------------------------------------------------------------------------

sub args_from_stdin { return 1 }

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems norecurse

=head1 NAME

App::Pinto::Admin::Command::pull - pull distributions from upstream repositories

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir pull [OPTIONS] TARGET ...
  pinto-admin --root=/some/dir pull [OPTIONS] < LIST_OF_TARGETS

=head1 DESCRIPTION

This command locate packages in your upstream repositories and then
pulls the distributions providing those packages into your repository.
Then it recursively locates and pulls all the distributions that are
necessary to satisfy their prerequisites.  You can also request to
directly pull particular distributions.

When locating packages, Pinto first looks at the the packages that
already exist in the local repository, then Pinto looks at the
packages that are available available on the upstream repositories.

You can also use this command to simply put packages into one stack or
another, and those packages (or their prerequisites) may or may not
already be in the repository.

=head1 COMMAND ARGUMENTS

Arguments are the targets that you want to pull.  Targets can be
specified as packages (with or without a minimum version number) or
a distributions.  For example:

  Foo::Bar                                 # Pulls any version of Foo::Bar
  Foo::Bar-1.2                             # Pulls Foo::Bar 1.2 or higher
  SHAKESPEARE/King-Lear-1.2.tar.gz         # Pulls a specific distribuion
  SHAKESPEARE/tragedies/Hamlet-4.2.tar.gz  # Ditto, but from a subdirectory

You can also pipe arguments to this command over STDIN.  In that case,
blank lines and lines that look like comments (i.e. starting with "#"
or ';') will be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --norecurse

Do not recursively pull any distributions required to satisfy
prerequisites for the targets.

=item --stack=NAME

Adds all the packages on the stack with the given NAME.  Defaults to the
name of whichever stack is currently marked as the master stack.  Use
the C<stack list> command to see the stacks in the repository.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

