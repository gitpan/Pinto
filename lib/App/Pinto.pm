package App::Pinto;

# ABSTRACT: Command-line driver for Pinto

use strict;
use warnings;

use App::Cmd::Setup -app;

#------------------------------------------------------------------------------

our $VERSION = '0.002'; # VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {
  return (
    [ "local=s"     => "Path to local repository directory"],
    [ "loglevel=s"  => "Set the amount of noise (debug|info|warn)" ],
    [ "nocleanup"   => "Do not clean repository after each action" ],
    [ "profile=s"   => "Path to your pinto profile" ],

  );
}

#------------------------------------------------------------------------------

sub usage_desc {
    return '%c [global options] <command>';
}

#------------------------------------------------------------------------------


sub pinto {
    my ($self) = @_;

    require Pinto;
    require Pinto::Config;

    return $self->{pinto} ||= do {
        my %global_options = %{ $self->global_options() };
        my $config = Pinto::Config->new(%global_options);
        my $pinto = Pinto->new(config => $config);
    };
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto - Command-line driver for Pinto

=head1 VERSION

version 0.002

=head1 DESCRIPTION

There is nothing to see here.  You probably should look at the
documentation for L<pinto> instead.

=head1 METHODS

=head2 pinto()

Returns a reference to the L<Pinto> object.  If it does not already
exist, one will be created using the global command options as
arguments.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

