package Pinto::Action::Update;

# ABSTRACT: An action to pull all the latest distributions into your repository

use Moose;

use MooseX::Types::Moose qw(Bool);

use URI;
use Try::Tiny;

use Pinto::Util;

use namespace::autoclean;

extends 'Pinto::Action';

#------------------------------------------------------------------------------

our $VERSION = '0.023'; # VERSION

#------------------------------------------------------------------------------
# Moose Attributes

has force => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------
# Moose Roles

with qw(Pinto::Role::UserAgent);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $idxmgr  = $self->idxmgr();
    my $idx_file = $idxmgr->mirror_index->file();
    my $idx_already_exists = -e $idx_file;  # HACK!

    my $idx_changes = $idxmgr->update_mirror_index( force => $self->force() );
    $self->store->add(file => $idx_file) if not $idx_already_exists;
    return 0 if not $idx_changes and not $self->force();

    my $dist_changes = 0;
    for my $dist ( $idxmgr->dists_to_mirror() ) {
        try   {
            $dist_changes += $self->_do_mirror($dist);
        }
        catch {
            $self->add_exception($_);
            $self->logger->whine("Download of $dist failed: $_");
        };
    }

    return 0 if not ($idx_changes + $dist_changes);

    my $source = $self->config->source();
    $self->add_message("Mirrored $dist_changes distributions from $source");

    return 1;
}

#------------------------------------------------------------------------------

sub _do_mirror {
    my ($self, $dist) = @_;

    my $repos   = $self->config->repos();
    my $source  = $self->config->source();
    my $cleanup = !$self->config->nocleanup();

    my $url = $dist->url($source);
    my $destination = $dist->path($repos);
    return 0 if -e $destination;

    $self->fetch(url => $url, to => $destination) or return 0;
    $self->store->add(file => $destination);

    my @removed = $self->idxmgr->add_mirrored_distribution(dist => $dist);
    $cleanup && $self->store->remove(file => $_->path($repos)) for @removed;

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Update - An action to pull all the latest distributions into your repository

=head1 VERSION

version 0.023

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
