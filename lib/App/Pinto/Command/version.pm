package App::Pinto::Command::version;

# ABSTRACT: show version information

use strict;
use warnings;

use Class::Load qw();

use base qw(App::Pinto::Command);

#-------------------------------------------------------------------------------

our $VERSION = '0.080'; # VERSION

#-------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my $app_class = ref $self->app();
    my $app_version = $self->app->VERSION || '?';
    print "$app_class $app_version\n";

    for my $pinto_class ( qw(Pinto Pinto::Remote) ) {
        Class::Load::try_load_class( $pinto_class ) or next;
        my $pinto_version = $pinto_class->VERSION || '?';
        print "$pinto_class $pinto_version\n";
    }

    return 0;
}

#-------------------------------------------------------------------------------


1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto::Command::version - show version information

=head1 VERSION

version 0.080

=head1 DESCRIPTION

This command simply displays some version information about this application.

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
