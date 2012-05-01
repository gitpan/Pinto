# ABSTRACT: Merge packages from one stack into another

package Pinto::Action::Stack::Merge;

use Moose;
use MooseX::Types::Moose qw(Bool Str);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------
# Attributes

has from_stack => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has to_stack => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has dryrun => (
    is       => 'ro',
    isa      => Bool,
    default  => 0,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $from_stk_name = $self->from_stack;
    my $to_stk_name = $self->to_stack;

    $self->notice("Merging stack $from_stk_name into stack $to_stk_name");

    my $did_merge = $self->repos->merge_stack( from   => $self->from_stack,
                                               to     => $self->to_stack,
                                               dryrun => $self->dryrun );

    $self->result->changed unless $self->dryrun;

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Stack::Merge - Merge packages from one stack into another

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
