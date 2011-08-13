package Pinto::Action::Mirror;

# ABSTRACT: An action to mirror a remote repository into your local one

use Moose;

use URI;
use Try::Tiny;

use Pinto::Util;
use Pinto::UserAgent;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.009'; # VERSION

#------------------------------------------------------------------------------
# Moose Roles

with qw(Pinto::Role::Downloadable);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $idxmgr  = $self->idxmgr();
    my $changes = $idxmgr->update_mirror_index() or return 0;
    my @dists   = $idxmgr->dists_to_mirror();

    for my $dist ( @dists ) {
        try   { $changes += $self->_do_fetch($dist) }
        catch { $self->logger->whine("Download of $dist failed: $_") };
    }

    if ($changes) {
        my $count  = @dists;
        my $source = $self->config->source();
        $self->add_message("Mirrored $count distributions from $source");
    }

    # Don't include an index change, just because --force was on
    $changes -= $self->config->force();

    return $changes;
}

#------------------------------------------------------------------------------

sub _do_fetch {
    my ($self, $dist) = @_;

    my $local   = $self->config->local();
    my $source  = $self->config->source();
    my $cleanup = !$self->config->nocleanup();

    my $url = $dist->url($source);
    my $destination = $dist->path($local);
    return 0 if -e $destination;

    $self->fetch(url => $url, to => $destination) or return 0;
    $self->store->add(file => $destination);

    my @removed = $self->idxmgr->add_mirrored_distribution(dist => $dist);
    $cleanup && $self->store->remove(file => $_->path($local)) for @removed;

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Mirror - An action to mirror a remote repository into your local one

=head1 VERSION

version 0.009

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
