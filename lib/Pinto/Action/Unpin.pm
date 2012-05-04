# ABSTRACT: Loosen a package that has been pinned

package Pinto::Action::Unpin;

use Moose;

use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_002'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Unpin );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->stack);

    $self->_execute($_, $stack) for $self->targets;

    return $self->result->changed;
}

#------------------------------------------------------------------------------

sub _execute {
    my ($self, $target, $stack) = @_;

    my $dist;
    if ($target->isa('Pinto::PackageSpec')) {

        my $pkg_name = $target->name;
        my $pkg = $self->repos->get_package(name => $pkg_name, stack => $stack)
            or throw "Package $pkg_name is not registered on stack $stack";

        $dist = $pkg->distribution;
    }
    elsif ($target->isa('Pinto::DistributionSpec')) {

        $dist = $self->repos->get_distribution(path => $target->path)
            or throw "Distribution $target does not exist";
    }
    else {

        my $type = ref $target;
        throw "Don't know how to pin target of type $type";
    }


    $self->notice("Unpinning $dist from stack $stack");
    $dist->unpin(stack => $stack);

    return;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Unpin - Loosen a package that has been pinned

=head1 VERSION

version 0.040_002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
