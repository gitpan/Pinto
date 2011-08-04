package Pinto::Action::Mirror;

# ABSTRACT: An action to fill the repository from a mirror

use Moose;

use URI;

use Pinto::Util;
use Pinto::UserAgent;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.006'; # VERSION

#------------------------------------------------------------------------------

has 'ua'      => (
    is         => 'ro',
    isa        => 'Pinto::UserAgent',
    default    => sub { Pinto::UserAgent->new() },
    init_arg   => undef,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $local  = $self->config->local();
    my $mirror = $self->config->mirror();
    my $force  = $self->config->force();

    my $idxmgr = $self->idxmgr();
    my $index_has_changed = $idxmgr->update_mirror_index();

    if (not $index_has_changed and not $force) {
        $self->logger->log("Mirror index has not changed");
        return 0;
    }

    for my $file ( $idxmgr->files_to_mirror() ) {

        my $mirror_uri = URI->new( "$mirror/authors/id/$file" );
        my $destination = Pinto::Util::native_file($local, 'authors', 'id', $file);
        next if -e $destination;

        my $file_has_changed = $self->ua->mirror(url => $mirror_uri, to => $destination, croak => 0);
        $self->logger->log("Mirrored archive $file") if $file_has_changed;
    }

    my $message = "Updated to latest mirror of $mirror";
    $self->_set_message($message);

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Mirror - An action to fill the repository from a mirror

=head1 VERSION

version 0.006

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
