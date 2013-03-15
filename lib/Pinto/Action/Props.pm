# ABSTRACT: Show or change stack properties

package Pinto::Action::Props;

use Moose;
use MooseX::MarkAsMethods (autoclean => 1);
use MooseX::Types::Moose qw(Str HashRef);

use String::Format qw(stringf);

use Pinto::Util qw(is_system_prop);
use Pinto::Types qw(StackName StackDefault StackObject);

#------------------------------------------------------------------------------

our $VERSION = '0.065_01'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Transactional
         Pinto::Role::Colorable );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | StackDefault | StackObject,
);


has properties => (
    is        => 'ro',
    isa       => HashRef,
    predicate => 'has_properties',
);


has format => (
    is      => 'ro',
    isa     => Str,
    default => "%p = %v",
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repo->get_stack($self->stack);

    $self->has_properties ? $self->_set_properties($stack)
                          : $self->_show_properties($stack);

    return $self->result;
}

#------------------------------------------------------------------------------

sub _set_properties {
    my ($self, $target) = @_;

    $target->set_properties($self->properties);
    $self->result->changed;

    return;
}

#------------------------------------------------------------------------------

sub _show_properties {
    my ($self, $target) = @_;

    my $props = $target->get_properties;
    while ( my ($prop, $value) = each %{$props} ) {

        my $string = stringf($self->format, {p => $prop, v => $value});
        my $color  = is_system_prop($prop) ? $self->color_3 : undef; 
        $string = $self->colorize_with_color($string, $color);

        $self->say($string);
    }

    return;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Props - Show or change stack properties

=head1 VERSION

version 0.065_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
