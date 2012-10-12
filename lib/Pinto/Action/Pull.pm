# ABSTRACT: Pull upstream distributions into the repository

package Pinto::Action::Pull;

use Moose;
use MooseX::Types::Moose qw(Bool);

use Module::CoreList;

use Pinto::Types qw(Specs StackName StackDefault);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.058'; # VERSION

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
    isa       => StackName | StackDefault,
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

#------------------------------------------------------------------------------


sub execute {
    my ($self) = @_;

    my $stack = $self->repos->open_stack(name => $self->stack);

    $self->_pull($_, $stack) for $self->targets;

    if ($self->result->made_changes and not $self->dryrun) {
        my $message = $self->edit_message(stacks => [$stack]);
        $stack->close(message => $message);
        $self->repos->write_index(stack => $stack);
    }

    return $self->result;
}

#------------------------------------------------------------------------------

sub _pull {
    my ($self, $target, $stack) = @_;

    if ($target->isa('Pinto::PackageSpec') && $self->_is_core_package($target, $stack)) {
        $self->debug("$target is part of the perl core.  Skipping it");
        return;
    }

    my ($dist, $did_pull) = $self->repos->find_or_pull(target => $target, stack => $stack);
    my $did_register = $dist ? $dist->register(stack => $stack, pin => $self->pin) : undef;

    if ($dist and not $self->norecurse) {
        $did_pull += $self->repos->pull_prerequisites(dist => $dist, stack => $stack);
    }

    $self->result->changed if $did_pull or $did_register;

    return;
}

#------------------------------------------------------------------------------

sub _is_core_package {
    my ($self, $pspec, $stack) = @_;

    my $wanted_package = $pspec->name;
    my $wanted_version = $pspec->version;

    return if not exists $Module::CoreList::version{ $] }->{$wanted_package};

    my $core_version = $Module::CoreList::version{ $] }->{$wanted_package};
    return $core_version >= $wanted_version;
}

#------------------------------------------------------------------------------

sub message_primer {
    my ($self) = @_;

    my $targets  = join ', ', $self->targets;
    my $pinned   = $self->pin       ? ' and pinned'            : '';
    my $prereqs  = $self->norecurse ? ' without prerequisites' : '';

    return "Pulled${pinned} ${targets}$prereqs.";
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

version 0.058

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
