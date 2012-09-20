# ABSTRACT: Show revision log for a stack

package Pinto::Action::Log;

use Moose;
use MooseX::Types::Moose qw(Bool Int Undef);

use Pinto::Types qw(StackName StackDefault);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.054'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | StackDefault,
    default   => undef,
    coerce    => 1,
);


has revision => (
    is        => 'ro',
    isa       => Int | Undef,
    default   => undef,
);


has detailed => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->stack);

    my $revnum = $self->revision;
    my @revisions = $stack->revision(number => $revnum);

    $self->fatal("No such revision $revnum on stack $stack")
      if !@revisions && defined $revnum;

    my $format = "%k\@%b | %j | %u\n\n%g\n";
    for my $revision (reverse @revisions) {
        $self->say('-' x 79);
        $self->say($revision->to_string($format));
        $self->say($revision->change_details) if $self->detailed;
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

Pinto::Action::Log - Show revision log for a stack

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
