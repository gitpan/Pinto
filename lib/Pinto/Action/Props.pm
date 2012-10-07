# ABSTRACT: Show stack properties

package Pinto::Action::Props;

use Moose;
use MooseX::Types::Moose qw(Str Maybe);

use String::Format;

use Pinto::Types qw(StackName StackDefault);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.057'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has stack  => (
    is        => 'ro',
    isa       => StackName | StackDefault,
    default   => undef,
    coerce    => 1,
);


has format => (
    is      => 'ro',
    isa     => Str,
    default => "%n = %v",
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repos->get_stack(name => $self->stack);

    my $props = $stack->get_properties;
    while ( my ($prop, $value) = each %{$props} ) {
        $self->say(stringf($self->format, {n => $prop, v => $value}));
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

Pinto::Action::Props - Show stack properties

=head1 VERSION

version 0.057

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
