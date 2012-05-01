# ABSTRACT: Add a local distribution into the repository

package Pinto::Action::Add;

use Moose;
use MooseX::Types::Moose qw(Bool);

use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Add
         Pinto::Role::PackageImporter );

#------------------------------------------------------------------------------

sub BUILD {
    my ($self, $args) = @_;

    my @missing = grep { not -e $_ } $self->archives;
    $self->error("Archive $_ does not exist") for @missing;

    my @unreadable = grep { -e $_ and not -r $_ } $self->archives;
    $self->error("Archive $_ is not readable") for @unreadable;

    throw "Some archives are missing or unreadable"
        if @missing or @unreadable;

    return $self;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->stack);

    $self->_execute($_, $stack) for $self->archives;

    return $self->result->changed;
}

#------------------------------------------------------------------------------

sub _execute {
    my ($self, $archive, $stack) = @_;

    $self->notice("Adding distribution archive $archive");

    my $dist  = $self->repos->add( archive   => $archive,
                                   author    => $self->author );

    $dist->register( stack => $stack );
    $dist->pin( stack => $stack ) if $self->pin;

    $self->pull_prerequisites( $dist, $stack ) unless $self->norecurse;

    return;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Add - Add a local distribution into the repository

=head1 VERSION

version 0.040_001

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
