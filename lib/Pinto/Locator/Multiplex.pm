# ABSTRACT: Find a package/distribution target among CPAN-like repositories

package Pinto::Locator::Multiplex;

use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::Locator::Mirror;
use Pinto::Locator::Stratopan;
use Pinto::Constants qw(:stratopan);

#------------------------------------------------------------------------------

our $VERSION = '0.0994_01'; # VERSION

#-----------------------------------------------------------------------------

extends qw(Pinto::Locator);

#------------------------------------------------------------------------------

has locators => (
    is         => 'ro',
    isa        => ArrayRef['Pinto::Locator'],
    writer     => '_set_locators',
    default    => sub { [] },
    lazy       => 1,
);

#------------------------------------------------------------------------------

sub assemble {
    my ($self, @uris) = @_;

    my @locators;
    for my $uri (@uris) {
        my $class = $self->locator_class_for_uri($uri);
        # Ick: This assumes all Locators have same attribute interface
        my %args = ( uri => $uri, cache_dir => $self->cache_dir );
        push @locators, $class->new( %args );
    }

    $self->_set_locators(\@locators);
    return $self;
}

#------------------------------------------------------------------------------

sub locate_package {
    my ($self, %args) = @_;

    my @all_found;
    for my $locator ( @{ $self->locators } ) {
        next unless my $found = $locator->locate_package(%args);
        push @all_found, $found;
        last unless $args{cascade};
    }

    return if not @all_found;
    @all_found = reverse sort {$a->{version} <=> $b->{version}} @all_found;
    return $all_found[0];
}

#------------------------------------------------------------------------------

sub locate_distribution {
    my ($self, %args) = @_;

    for my $locator ( @{ $self->locators } ) {
        next unless my $found = $locator->locate_distribution(%args);
        return $found;
    }

    return;
}

#------------------------------------------------------------------------------

sub locator_class_for_uri {
    my ($self, $uri) = @_;

    my $baseclass = 'Pinto::Locator';
    my $subclass  = $uri eq $PINTO_STRATOPAN_CPAN_URI ? 'Stratopan' : 'Mirror';

    return $baseclass . '::' . $subclass;
}

#------------------------------------------------------------------------------


sub refresh {
    my ($self) = @_;

    $_->refresh for @{ $self->locators };

    return $self;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux brian d foy hesco popl Däppen Cory
G Watson David Steinbrunner Glenn

=head1 NAME

Pinto::Locator::Multiplex - Find a package/distribution target among CPAN-like repositories

=head1 VERSION

version 0.0994_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
