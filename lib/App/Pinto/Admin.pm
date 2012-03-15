package App::Pinto::Admin;

# ABSTRACT: Command-line driver for Pinto::Admin

use strict;
use warnings;

use Class::Load qw();

use App::Cmd::Setup -app;

#------------------------------------------------------------------------------

our $VERSION = '0.033'; # VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {

  return (
      [ 'root|r=s'    => 'Path to your repository root directory' ],
      [ 'nocolor'     => 'Do not colorize diagnostic messages' ],
      [ 'quiet|q'     => 'Only report fatal errors' ],
      [ 'verbose|v+'  => 'More diagnostic output (repeatable)' ],
  );
}

#------------------------------------------------------------------------------


sub pinto {
    my ($self) = @_;

    return $self->{pinto} ||= do {
        my %global_options = %{ $self->global_options() };

        $global_options{root} ||= $ENV{PINTO_REPOSITORY_ROOT}
            || $self->usage_error('Must specify a repository root directory');

        my $pinto_class = $self->pinto_class();
        Class::Load::load_class($pinto_class);
        my $pinto = $pinto_class->new(%global_options);
    };
}

#------------------------------------------------------------------------------

sub pinto_class { return 'Pinto' }

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin - Command-line driver for Pinto::Admin

=head1 VERSION

version 0.033

=head1 METHODS

=head2 pinto()

Returns a reference to a L<Pinto> object that has been constructed for
this application.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
