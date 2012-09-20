# ABSTRACT: Pull upstream distributions into the repository

package Pinto::Action::Pull;

use Moose;
use MooseX::Types::Moose qw(Undef Bool);

use Pinto::Types qw(Specs StackName);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.055'; # VERSION

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
    isa       => StackName | Undef,
    default   => undef,
    coerce    => 1,
);


has pin => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);


has norecurse => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);


has dryrun => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------


sub execute {
    my ($self) = @_;

    my $stack = $self->repos->open_stack(name => $self->stack);

    $self->_execute($_, $stack) for $self->targets;
    $self->result->changed if $stack->refresh->has_changed;

    if ($stack->has_changed and not $self->dryrun) {
        my $message_primer = $stack->head_revision->change_details;
        my $message = $self->edit_message(primer => $message_primer);
        $stack->close(message => $message);
        $self->repos->write_index(stack => $stack);
    }

    return $self->result;
}

#------------------------------------------------------------------------------

sub _execute {
    my ($self, $target, $stack) = @_;

    my ($dist, $did_pull) = $self->repos->get_or_pull( target => $target,
                                                       stack  => $stack );

    $dist->pin( stack => $stack ) if $dist && $self->pin;

    if ($dist and not $self->norecurse) {
        my @prereq_dists = $self->repos->pull_prerequisites( dist  => $dist,
                                                             stack => $stack );
    }

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

version 0.055

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
