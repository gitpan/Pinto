package App::Pinto::Admin::Command::nop;

# ABSTRACT: initialize Pinto and exit

use strict;
use warnings;

use Pinto::Util;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.025_004'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'noinit'  => 'Do not pull/update from VCS' ],
        [ 'sleep=i' => 'seconds to sleep before exiting' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Arguments are not allowed')
      if @{ $args };

    $self->usage_error('Sleep time must be positive integer')
      if defined $opts->{sleep} && $opts->{sleep} < 1;

    return 1;
}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::nop - initialize Pinto and exit

=head1 VERSION

version 0.025_004

=head1 SYNOPSIS

  pinto-admin --repos=/some/dir nop [OPTIONS]

=head1 DESCRIPTION

This command is a no-operation.  It locks and initializes the
repository, but does not perform any operations.  This is really only
used for diagnostic purposes.  So don't worry about it too much.

Note this command never changes the state of your repository.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

=over 4

=item --noinit

Prevents L<Pinto> from pulling/updating the repository from the VCS
before the operation.  This is only relevant if you are using a
VCS-based storage mechanism.  This can speed up operations
considerably, but should only be used if you *know* that your working
copy is up-to-date and you are going to be the only actor touching the
Pinto repository within the VCS.

=item --sleep=N

Directs L<Pinto> to sleep for N seconds before releasing the lock and
exiting.  Default is 0.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
