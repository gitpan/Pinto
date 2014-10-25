package Pinto::Action::Remove;

# ABSTRACT: An action to remove packages from the repository

use Moose;
use MooseX::Types::Moose qw( Str );

use Pinto::Util;
use Pinto::Types qw(AuthorID);

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.012'; # VERSION

#------------------------------------------------------------------------------

has package  => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has author => (
    is         => 'ro',
    isa        => AuthorID,
    coerce     => 1,
    lazy_build => 1,
);

#------------------------------------------------------------------------------

sub _build_author { return shift()->config->author() }

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $pkg    = $self->package();
    my $author = $self->author();
    my $idxmgr = $self->idxmgr();

    my $dist = $idxmgr->remove_local_package(package => $pkg, author => $author);
    $self->logger->whine("Package $pkg is not in the local index") and return 0 if not $dist;
    $self->logger->info(sprintf "Removing $dist with %i packages", $dist->package_count());

    my $file = $dist->path( $self->config->local() );
    $self->config->nocleanup() || $self->store->remove( file => $file );

    $self->add_message( Pinto::Util::removed_dist_message( $dist ) );

    return 1;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Remove - An action to remove packages from the repository

=head1 VERSION

version 0.012

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
