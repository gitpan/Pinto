# ABSTRACT: List known stacks in the repository

package Pinto::Action::Stack::List;

use Moose;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Stack::List );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $attrs = { order_by => 'name' };
    my @stacks = $self->repos->db->select_stacks(undef, $attrs)->all;

    for my $stack ( @stacks ) {
        print { $self->out } $stack->to_string($self->format);
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

Pinto::Action::Stack::List - List known stacks in the repository

=head1 VERSION

version 0.040_001

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
