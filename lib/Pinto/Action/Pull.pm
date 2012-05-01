# ABSTRACT: Pull upstream distributions into the repository

package Pinto::Action::Pull;

use Moose;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Pull
         Pinto::Role::PackageImporter );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->stack);

    $self->_execute($_, $stack) for $self->targets;

    return $self->result;
}

#------------------------------------------------------------------------------

sub _execute {
    my ($self, $target, $stack) = @_;

    my ($dist, $did_pull) = $self->find_or_pull( $target, $stack );
    return if not $dist;

    unless ( $self->norecurse ) {
        my @prereq_dists = $self->pull_prerequisites( $dist, $stack );
        $did_pull += @prereq_dists;
    }

    $self->result->changed if $did_pull;

    return;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Pull - Pull upstream distributions into the repository

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
