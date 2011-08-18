package App::Pinto::Admin;

# ABSTRACT: Command-line driver for Pinto

use strict;
use warnings;

use App::Cmd::Setup -app;

#------------------------------------------------------------------------------

our $VERSION = '0.015'; # VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {

  return (

#      [ "config=s"    => "Path to your pinto config file" ],
      [ "local=s"     => "Path to local repository directory"],
      [ "nocleanup"   => "Do not remove distribtuions that become outdated" ],
      [ "nocommit"    => "Do not commit changes to VCS" ],
      [ "noinit"      => "Skip updating or pulling from VCS" ],
      [ "notag"       => "Do not make tag after committing to VCS" ],
      [ "quiet|q"     => "Only report fatal errors"],
      [ "verbose|v+"  => "More diagnostic output (repeatable)" ],
  );
}

#------------------------------------------------------------------------------

sub usage_desc {
    return '%c [global options] <command>';
}

#------------------------------------------------------------------------------


sub pinto {
    my ($self, $command_options) = @_;

    require Pinto;
    require Pinto::Config;
    require Pinto::Logger;

    return $self->{pinto} ||= do {
        my %global_options = %{ $self->global_options() };
        my $config = Pinto::Config->new(%global_options, %{$command_options});
        my $logger = Pinto::Logger->new(config => $config);
        my $pinto  = Pinto->new(config => $config, logger => $logger);
    };
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin - Command-line driver for Pinto

=head1 VERSION

version 0.015

=head1 DESCRIPTION

There is nothing to see here.  You probably should look at the
documentation for L<pinto> instead.

=head1 METHODS

=head2 pinto( $command_options )

Returns a reference to the L<Pinto> object.  If it does not already
exist, one will be created using the global and command options.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

