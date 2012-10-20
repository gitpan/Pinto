# ABSTRACT: Force a package to stay in a stack

package Pinto::Action::Pin;

use Moose;

use Pinto::Types qw(Specs StackName StackDefault);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.059'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | StackDefault,
    default   => undef,
);


has targets => (
    isa      => Specs,
    traits   => [ qw(Array) ],
    handles  => {targets => 'elements'},
    required => 1,
    coerce   => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->open_stack(name => $self->stack);
    $self->_pin($_, $stack) for $self->targets;

    if ($self->result->made_changes and not $self->dryrun) {
        my $message = $self->edit_message(stacks => [$stack]);
        $stack->close(message => $message);
    }

    return $self->result;
}

#------------------------------------------------------------------------------

sub _pin {
    my ($self, $spec, $stack) = @_;

    my $dist = $self->repos->get_distribution_by_spec(spec => $spec, stack => $stack);

    throw "$spec does not exist in the repository" if not $dist;

    $self->notice("Pinning distribution $dist to stack $stack");

    $self->result->changed if $dist->pin(stack => $stack);

    return;
}

#------------------------------------------------------------------------------

sub message_primer {
    my ($self) = @_;

    my $targets  = join ', ', $self->targets;

    return "Pinned ${targets}.";
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Pin - Force a package to stay in a stack

=head1 VERSION

version 0.059

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
