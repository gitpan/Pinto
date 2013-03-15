# ABSTRACT: Something that wants to colorize strings

package Pinto::Role::Colorable;

use Moose::Role;
use MooseX::Types::Moose qw(Str Bool ArrayRef);
use MooseX::MarkAsMethods (autoclean => 1);

use Term::ANSIColor qw(color colorvalid);

use Pinto::Exception qw(throw);

#-----------------------------------------------------------------------------

our $VERSION = '0.065_01'; # VERSION

#-----------------------------------------------------------------------------

has no_color => (
    is         => 'ro',
    isa        => Bool,
    default    => sub { $ENV{PINTO_NO_COLOR} || $ENV{PINTO_NO_COLOUR} || 0 },
);


has color_0 => (
	is        => 'ro',
	isa       => Str,
	default   => sub { color('reset') },
);


has color_1 => (
	is        => 'ro',
	isa       => Str,
	default   => sub { color($_[0]->user_colors->[0] || 'green') },
	lazy      => 1,
);


has color_2 => (
	is        => 'ro',
	isa       => Str,
	default   => sub { color($_[0]->user_colors->[1] || 'yellow') },
	lazy      => 1,
);


has color_3 => (
	is        => 'ro',
	isa       => Str,
	default   => sub { color($_[0]->user_colors->[2] || 'red') },
	lazy      => 1,
);


has user_colors => (
	is        => 'ro',
	isa       => ArrayRef,
	default   => sub { [split m/\s*,\s*/, $ENV{PINTO_COLORS} || $ENV{PINTO_COLOURS} || ''] },
	lazy      => 1,
);

#-----------------------------------------------------------------------------

sub colorize_with_color {
	my ($self, $string, $color) = @_;

	return $string if not $color;
	return $string if $self->no_color;
	return $color . $string . $self->color_0;
}

#-----------------------------------------------------------------------------

sub colorize_with_color_1 {
	my ($self, $string) = @_;

	return $string if $self->no_color;
	return $self->color_1 . $string . $self->color_0;
}

#-----------------------------------------------------------------------------

sub colorize_with_color_2 {
	my ($self, $string) = @_;

	return $string if $self->no_color;
	return $self->color_2 . $string . $self->color_0;
}

#-----------------------------------------------------------------------------

sub colorize_with_color_3 {
	my ($self, $string) = @_;

	return $string if $self->no_color;
	return $self->color_3 . $string . $self->color_0;
}

#-----------------------------------------------------------------------------

sub BUILD {
    my ($self) = @_;

	colorvalid($_) || throw "User color $_ is not valid" for @{ $self->user_colors };

	return $self;
};

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Colorable - Something that wants to colorize strings

=head1 VERSION

version 0.065_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
