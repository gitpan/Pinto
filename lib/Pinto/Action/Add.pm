# ABSTRACT: Add a local distribution into the repository

package Pinto::Action::Add;

use Moose;
use MooseX::Types::Moose qw(Bool Str);

use Pinto::Types qw(Author Files StackName StackDefault);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.058'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::PauseConfig Pinto::Role::Committable );

#------------------------------------------------------------------------------

has author => (
    is         => 'ro',
    isa        => Author,
    default    => sub { uc ($_[0]->pausecfg->{user} || $_[0]->config->username) },
    coerce     => 1,
    lazy       => 1,
);


has archives  => (
    isa       => Files,
    traits    => [ qw(Array) ],
    handles   => {archives => 'elements'},
    required  => 1,
    coerce    => 1,
);


has stack => (
    is       => 'ro',
    isa      => StackName | StackDefault,
    default  => undef,
    coerce   => 1,
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

    my $stack = $self->repos->open_stack(name => $self->stack);
    $self->_add($_, $stack) for $self->archives;

    if ($self->result->made_changes and not $self->dryrun) {
        my $message = $self->edit_message(stacks => [$stack]);
        $stack->close(message => $message);
        $self->repos->write_index(stack => $stack);
    }

    return $self->result;
}

#------------------------------------------------------------------------------

sub _add {
    my ($self, $archive, $stack) = @_;

    $self->notice("Adding distribution archive $archive");

    my $dist = $self->repos->add(archive => $archive, author => $self->author);

    $dist->register(stack => $stack, pin => $self->pin);

    $self->repos->pull_prerequisites(dist => $dist, stack => $stack) unless $self->norecurse;

    return $self->result->changed;
}

#------------------------------------------------------------------------------

sub message_primer {
    my ($self) = @_;

    my $archives  = join ', ', map {$_->basename} $self->archives;
    my $pinned    = $self->pin       ? ' and pinned'            : '';
    my $prereqs   = $self->norecurse ? ' without prerequisites' : '';

    return "Added${pinned} ${archives}$prereqs.";
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Add - Add a local distribution into the repository

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
