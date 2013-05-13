# ABSTRACT: Remove orphaned archives

package Pinto::Action::Clean;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods (autoclean => 1);

#------------------------------------------------------------------------------

our $VERSION = '0.083'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    $self->repo->optimize_database;
    
    my $did_delete = $self->repo->clean_files;

    $self->result->changed if $did_delete;

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Action::Clean - Remove orphaned archives

=head1 VERSION

version 0.083

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

=item *

hesco <hesco@campaignfoundations.com>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
