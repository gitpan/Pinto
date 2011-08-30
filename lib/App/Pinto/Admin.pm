package App::Pinto::Admin;

# ABSTRACT: Command-line driver for pinto-admin

use strict;
use warnings;

use App::Cmd::Setup -app;

#------------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {

  return (
      [ 'repos|r=s'   => 'Path to your repository directory' ],
      [ 'nocolor'     => 'Do not colorize diagnostic messages' ],
      [ 'quiet|q'     => 'Only report fatal errors' ],
      [ 'verbose|v+'  => 'More diagnostic output (repeatable)' ],
  );
}

#------------------------------------------------------------------------------

sub usage_desc {
    return '%c [global options] <command> [command options]';
}

#------------------------------------------------------------------------------


sub pinto {
    my ($self) = @_;

    return $self->{pinto} ||= do {

        my %global_options = %{ $self->global_options() };

        $global_options{repos}
            or $self->usage_error('Must specify a repository');

        require Pinto;
        my $pinto  = Pinto->new(%global_options);
    };
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin - Command-line driver for pinto-admin

=head1 VERSION

version 0.021

=head1 DESCRIPTION

There is nothing to see here.  You probably should look at the
documentation for L<pinto> instead.

=head1 METHODS

=head2 pinto()

Returns a reference to the L<Pinto> object.  If it does not already
exist, one will be created using the global options.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

