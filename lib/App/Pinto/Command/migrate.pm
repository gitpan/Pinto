# ABSTRACT: migrate repository to a new version

package App::Pinto::Command::migrate;

use strict;
use warnings;

use Class::Load;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.079_04'; # VERSION

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Arguments are not allowed')
      if @{ $args };

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my $global_opts = $self->app->global_options;

    $global_opts->{root} ||= $ENV{PINTO_REPOSITORY_ROOT}
        || die "Must specify a repository root directory\n";

    $global_opts->{root} =~ m{^https?://}x
        && die "Cannot migrate remote repositories\n";

    my $class = $self->load_migrator;
    my $migrator = $class->new( %{ $global_opts } );
    $migrator->migrate;

    return 0;
}

#------------------------------------------------------------------------------

sub load_migrator {

    my $class = 'Pinto::Migrator';

    my ($ok, $error) = Class::Load::try_load_class($class);
    return $class if $ok;

    my $msg = $error =~ m/Can't locate .* in \@INC/  ## no critic (ExtendedFormat)
                     ? "Must install Pinto to migrate repositories\n"
                     : $error;
    die $msg;
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::migrate - migrate repository to a new version

=head1 VERSION

version 0.079_04

=head1 SYNOPSIS

  pinto --root=REPOSITORY_ROOT migrate

=head1 DESCRIPTION

This command migrates an existing repository to a format that is compatible
with the current version of L<Pinto> that you have.  At present, it only
works for repositories created with version 0.070 or later.  If you need
to migrate a repository that was created with an earlier version, please
contact C<thaljef@cpan.org> and I'll help you come up with a migration
plan that fits your situation.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

None.

=head1 CONTRIBUTORS

=over 4

=item *

Cory G Watson <gphat@onemogin.com>

=item *

Jakob Voss <jakob@nichtich.de>

=item *

Jeff <jeff@callahan.local>

=item *

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=item *

Jeffrey Thalhammer <jeff@imaginative-software.com>

=item *

Karen Etheridge <ether@cpan.org>

=item *

Michael G. Schwern <schwern@pobox.com>

=item *

Steffen Schwigon <ss5@renormalist.net>

=item *

Wolfgang Kinkeldei <wolfgang@kinkeldei.de>

=item *

Yanick Champoux <yanick@babyl.dyndns.org>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
