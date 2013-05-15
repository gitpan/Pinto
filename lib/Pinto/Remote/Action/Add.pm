# ABSTRACT: Add a distribution to a the repository

package Pinto::Remote::Action::Add;

use Moose;
use MooseX::MarkAsMethods (autoclean => 1);

use JSON;

use Pinto::Util qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.084'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Remote::Action );

#------------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $args = $class->$orig(@_);

    # I don't have a separate attribute for each action argument, 
    # so I need to wedge in the default author identity somehow.
    # And if PINTO_AUTHOR_ID isn't defined either, then the server
    # will fall back to using the username.  Perhaps I could also
    # do the same thing here just to make it clear what's going on.
    
    $args->{args}->{author} ||= $ENV{PINTO_AUTHOR_ID} if $ENV{PINTO_AUTHOR_ID};

    return $args;
};

#------------------------------------------------------------------------------

sub BUILD {
    my ($self) = @_;

    throw 'Only one archive can be remotely added at a time'
      if @{ $self->args->{archives} || [] } > 1;

    return $self;
}

#------------------------------------------------------------------------------

override _make_request_body => sub {
    my ($self) = @_;

    my $body = super;
    my $archive = (delete $self->args->{archives})->[0];
    push @{ $body }, (archives => [$archive]);

    return $body;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Remote::Action::Add - Add a distribution to a the repository

=head1 VERSION

version 0.084

=for Pod::Coverage BUILD

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
