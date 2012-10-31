# ABSTRACT: Create a new stack by copying another

package Pinto::Action::Copy;

use Moose;
use MooseX::Types::Moose qw(Str Bool);

use Pinto::Types qw(StackName);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.061'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

has from_stack => (
    is       => 'ro',
    isa      => StackName,
    required => 1,
);


has to_stack => (
    is       => 'ro',
    isa      => StackName,
    required => 1,
);


has default => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);


has description => (
    is         => 'ro',
    isa        => Str,
    predicate  => 'has_description',
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $orig = $self->repo->get_stack(name => $self->from_stack);
    my $copy = $self->repo->copy_stack(from => $orig, to => $self->to_stack);

    my $description = $self->description || "copy of stack $orig";
    $copy->set_property(description => $description);

    my $message = $self->edit_message(stacks => [$copy]);
    $copy->close(message => $message);

    $copy->mark_as_default if $self->default;

    $self->repo->create_stack_filesystem(stack => $copy);
    $self->repo->write_index(stack => $copy);

    return $self->result->changed;
}

#------------------------------------------------------------------------------

sub message_primer {
    my ($self) = @_;

    my $orig = $self->repo->get_stack(name => $self->from_stack);
    my $copy = $self->repo->get_stack(name => $self->to_stack);

    return "Copied stack $orig to stack $copy.";
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Copy - Create a new stack by copying another

=head1 VERSION

version 0.061

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
