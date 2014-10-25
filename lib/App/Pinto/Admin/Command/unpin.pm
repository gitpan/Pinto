package App::Pinto::Admin::Command::unpin;

# ABSTRACT: free a packages that have been pinned

use strict;
use warnings;

use Pinto::Util;

#------------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'stack|s=s' => 'Stack from which to unpin the target' ],
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

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::unpin - free a packages that have been pinned

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir unpin [OPTIONS] TARGET ...
  pinto-admin --root=/some/dir unpin [OPTIONS] < LIST_OF_TARGETS

=head1 DESCRIPTION

This command unpins package in the stack, so that the stack can be
merged into another stack with a newer packages, or so the packages
can be upgraded to a newer version within this stack.

=head1 COMMAND ARGUMENTS

Arguments are the targets you wish to unpin.  Targets can be
specified as packages or distributions, such as:

  Some::Package
  Some::Other::Package

  AUTHOR/Some-Dist-1.2.tar.gz
  AUTHOR/Some-Other-Dist-1.3.zip

When unpinning a distribution, all the packages in that distribution
become unpinned.  Likewise when unpinning a package, all its sister
packages in the same distributon also become unpinned.

You can also pipe arguments to this command over STDIN.  In that case,
blank lines and lines that look like comments (i.e. starting with "#"
or ';') will be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --stack=NAME

Unpins the package on the stack with the given NAME.  Defaults to the
name of whichever stack is currently marked as the master stack.  Use
the C<stack list> command to see your stacks.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


