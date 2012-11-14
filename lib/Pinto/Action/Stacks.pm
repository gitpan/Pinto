# ABSTRACT: List known stacks in the repository

package Pinto::Action::Stacks;

use Moose;
use MooseX::Types::Moose qw(Str);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.065'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has format => (
    is      => 'ro',
    isa     => Str,
    default => "%M %-16k %-16j %u",
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    for my $stack ( sort {$a cmp $b} $self->repo->get_all_stacks ) {
        $self->say($stack->to_string($self->format));
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

Pinto::Action::Stacks - List known stacks in the repository

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
