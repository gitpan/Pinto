package App::Pinto::Admin::Command::nop;

# ABSTRACT: initialize Pinto and exit

use strict;
use warnings;

use Pinto::Util;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'sleep=i' => 'seconds to sleep before exiting' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->SUPER::validate_args($opts, $args);

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

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir nop [OPTIONS]

=head1 DESCRIPTION

This command is a no-operation.  It locks and initializes the
repository, but does not perform any operations.  This is really only
used for diagnostic purposes.  So don't worry about it too much.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

=over 4

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

