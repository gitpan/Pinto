package Pinto::Action::Add;

# ABSTRACT: An action to add one local distribution to the repository

use Moose;

use Path::Class;
use File::Temp;

use Pinto::Util;
use Pinto::Distribution;
use Pinto::Types 0.017 qw(StrOrFileOrURI);

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.024'; # VERSION

#------------------------------------------------------------------------------
# Attrbutes

has dist_file => (
    is       => 'ro',
    isa      => StrOrFileOrURI,
    required => 1,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::UserAgent
         Pinto::Role::Authored );

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $repos     = $self->config->repos();
    my $cleanup   = not $self->config->nocleanup();
    my $author    = $self->author();
    my $dist_file = $self->dist_file();

    # TODO: Consider moving Distribution construction to the index manager
    $dist_file = _is_url($dist_file) ? $self->_dist_from_url($dist_file) : file($dist_file);
    my $added = Pinto::Distribution->new_from_file(file => $dist_file, author => $author);

    my @removed = $self->idxmgr->add_local_distribution(dist => $added, file => $dist_file);
    $self->logger->info(sprintf "Adding $added with %i packages", $added->package_count());

    $self->store->add( file => $added->path($repos), source => $dist_file );
    $cleanup && $self->store->remove( file => $_->path($repos) ) for @removed;

    $self->add_message( Pinto::Util::added_dist_message($added) );
    $self->add_message( Pinto::Util::removed_dist_message($_) ) for @removed;

    return 1;
};

#------------------------------------------------------------------------------

sub _is_url {
    my ($it) = @_;

    return 1 if eval { $it->isa('URI') };
    return 0 if eval { $it->isa('Path::Class::File') };
    return $it =~ m/^ (?: http|ftp|file|) : /x;
}

#------------------------------------------------------------------------------

sub _dist_from_url {
    my ($self, $dist_url) = @_;

    my $url = URI->new($dist_url)->canonical();
    my $path = Path::Class::file( $url->path() );
    return $path if $url->scheme() eq 'file';

    my $base     = $path->basename();
    my $tempdir  = File::Temp::tempdir(CLEANUP => 1);
    my $tempfile = Path::Class::file($tempdir, $base);

    $self->fetch(url => $url, to => $tempfile);

    return Path::Class::file($tempfile);
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Add - An action to add one local distribution to the repository

=head1 VERSION

version 0.024

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
