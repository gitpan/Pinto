package Pinto::IndexCache;

# ABSTRACT: Manages indexes files from remote repositories

use Moose;

use Package::Locator;

use namespace::autoclean;

#-------------------------------------------------------------------------------

our $VERSION = '0.043'; # VERSION

#-------------------------------------------------------------------------------
# Attributes

has locator => (
    is         => 'ro',
    isa        => 'Package::Locator',
    lazy_build => 1,
);

#-------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#-------------------------------------------------------------------------------

sub _build_locator {
    my ($self) = @_;

    my @urls    = $self->config->sources_list();
    my $locator = Package::Locator->new( repository_urls => \@urls,
                                         cache_dir       => $self->config->cache_dir() );

    return $locator;
}

#-------------------------------------------------------------------------------

sub locate {
    my ($self, @args) = @_;

    return $self->locator->locate(@args);
}

#-------------------------------------------------------------------------------

sub contents {
    my ($self) = @_;

    my %seen;
    for my $index ( $self->locator->indexes() ) {
        for my $dist ( values %{ $index->distributions() } ) {
            next if exists $seen{ $dist->{path} };
            $dist->{packages} ||= []; # Prevent possible undef
            delete $_->{distribution} for @{ $dist->{packages} };
            $seen{ $dist->{path} } = $dist;
        }
    }

    return @seen{ sort keys %seen };

}
#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::IndexCache - Manages indexes files from remote repositories

=head1 VERSION

version 0.043

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
