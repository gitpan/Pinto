package Pinto::Action::Remove;

# ABSTRACT: An action to remove one local distribution from the repository

use Moose;
use MooseX::Types::Moose qw( Str );

use Pinto::Util;
use Pinto::Exception;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.023'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has dist_name  => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Authored );

#------------------------------------------------------------------------------


override execute => sub {
    my ($self) = @_;

    my $dist_name  = $self->dist_name();
    my $author     = $self->author();
    my $idxmgr     = $self->idxmgr();
    my $cleanup    = not $self->config->nocleanup();

    # If the $dist_name looks like a precise location (i.e. it has
    # slashes), then use it as such.  But if not, then use the author
    # attribute to construct the precise location.
    my $location = $dist_name =~ m{/}mx ?
      $dist_name : Pinto::Util::author_dir($author)->file($dist_name)->as_foreign('Unix');

    # TODO: throw a more specialized exception.
    my $dist = $idxmgr->remove_local_distribution_at(location => $location)
        or Pinto::Exception->throw("Distribution $location is not in the local index");

    $self->logger->info(sprintf "Removing $dist with %i packages", $dist->package_count());

    my $file = $dist->path( $self->config->repos() );
    $self->store->remove( file => $file ) if $cleanup;

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

Pinto::Action::Remove - An action to remove one local distribution from the repository

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
