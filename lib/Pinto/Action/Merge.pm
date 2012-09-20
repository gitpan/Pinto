# ABSTRACT: Merge packages from one stack into another

package Pinto::Action::Merge;

use Moose;
use MooseX::Types::Moose qw(Bool);

use Pinto::Types qw(StackName);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.054'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

has from_stack => (
    is       => 'ro',
    isa      => StackName,
    required => 1,
    coerce   => 1,
);


has to_stack => (
    is       => 'ro',
    isa      => StackName,
    required => 1,
    coerce   => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $from_stack = $self->repos->get_stack(name => $self->from_stack);
    my $to_stack   = $self->repos->open_stack(name => $self->to_stack);

    $self->notice("Merging stack $from_stack into stack $to_stack");

    $from_stack->merge(to => $to_stack);
    $self->result->changed if $to_stack->refresh->has_changed;

    if ($to_stack->has_changed and not $self->dryrun) {
        my $message_primer = $to_stack->head_revision->change_details;
        my $message = $self->edit_message(primer => $message_primer);
        $to_stack->close(message => $message, committed_by => $self->username);
        $self->repos->write_index(stack => $to_stack);
    }

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Merge - Merge packages from one stack into another

=head1 VERSION

version 0.054

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
