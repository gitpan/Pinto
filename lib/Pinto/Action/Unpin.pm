# ABSTRACT: Loosen a package that has been pinned

package Pinto::Action::Unpin;

use Moose;

use Pinto::Types qw(Specs StackName StackDefault StackObject);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.065'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

has targets => (
    isa      => Specs,
    traits   => [ qw(Array) ],
    handles  => {targets => 'elements'},
    required => 1,
    coerce   => 1,
);


has stack => (
    is        => 'ro',
    isa       => StackName | StackDefault | StackObject,
    default   => undef,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repo->open_stack($self->stack);

    $self->_unpin($_, $stack) for $self->targets;

    if ( $self->result->made_changes and not $self->dryrun ) {
        my $message = $self->edit_message(stacks => [$stack]);
        $stack->close(message => $message);
    }

    return $self->result;
}

#------------------------------------------------------------------------------

sub _unpin {
    my ($self, $spec, $stack) = @_;

    my $dist = $self->repo->get_distribution_by_spec(spec => $spec, stack => $stack);

    throw "$spec does not exist in the repository" if not $dist;

    $self->notice("Unpinning distribution $dist from stack $stack");

    $self->result->changed if $dist->unpin(stack => $stack);

    return;
}

#------------------------------------------------------------------------------

sub message_title {
    my ($self) = @_;

    my $targets  = join ', ', $self->targets;

    return "Unpinned ${targets}.";
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Unpin - Loosen a package that has been pinned

=head1 VERSION

version 0.065

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
