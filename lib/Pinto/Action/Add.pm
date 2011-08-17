package Pinto::Action::Add;

# ABSTRACT: An action to add one distribution to the repository

use Moose;

use Pinto::Util;
use Pinto::Distribution;
use Pinto::Types qw(File AuthorID);

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.012'; # VERSION

#------------------------------------------------------------------------------
# Attrbutes

has dist => (
    is       => 'ro',
    isa      => File,
    required => 1,
    coerce   => 1,
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

    my $local     = $self->config->local();
    my $cleanup   = not $self->config->nocleanup();
    my $author    = $self->author();
    my $dist_file = $self->dist();

    my $added   = Pinto::Distribution->new_from_file(file => $dist_file, author => $author);
    my @removed = $self->idxmgr->add_local_distribution(dist => $added);
    $self->logger->info(sprintf "Adding $added with %i packages", $added->package_count());

    $self->store->add( file => $added->path($local), source => $dist_file );
    $cleanup && $self->store->remove( file => $_->path($local) ) for @removed;

    $self->add_message( Pinto::Util::added_dist_message($added) );
    $self->add_message( Pinto::Util::removed_dist_message($_) ) for @removed;

    return 1;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Add - An action to add one distribution to the repository

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
