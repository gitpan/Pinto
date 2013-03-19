# ABSTRACT: Iterates through distribution prerequisites

package Pinto::PrerequisiteWalker;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(CodeRef ArrayRef HashRef Bool);
use MooseX::MarkAsMethods (autoclean => 1);

#------------------------------------------------------------------------------

our $VERSION = '0.065_03'; # VERSION

#------------------------------------------------------------------------------

has start => (
	is       => 'ro',
	isa      => 'Pinto::Schema::Result::Distribution',
	required => 1,
);


has callback => (
	is       => 'ro',
	isa      => CodeRef,
	required => 1,
);


has filter => (
  is        => 'ro',
  isa       => CodeRef,
  predicate => 'has_filter',
);


has queue => (
  isa       => ArrayRef['Pinto::PackageSpec'],
  traits    => [ qw(Array) ],
  handles   => {enqueue => 'push', dequeue => 'shift'},
  default   => sub { return [ $_[0]->apply_filter($_[0]->start->prerequisite_specs) ] },
  init_arg  => undef,
  lazy      => 1,
);


has seen => (
  is       => 'ro',
  isa      => HashRef,
  default  => sub { return { $_[0]->start->path => 1 } },
  init_arg => undef,
  lazy     => 1,
);

#-----------------------------------------------------------------------------

sub next {
  my ($self) = @_;

  my $prereq = $self->dequeue or return;
  my $dist   = $self->callback->($prereq);

  if (defined $dist) {
    my $path    = $dist->path;
    my @prereqs = $self->apply_filter($dist->prerequisite_specs);
    $self->enqueue(@prereqs) unless $self->seen->{$path};
    $self->seen->{$path} = 1;
  }

  return $prereq;
}

#------------------------------------------------------------------------------

sub apply_filter {
  my ($self, @prereqs) = @_;

  return @prereqs if not $self->has_filter;

  return grep { ! $self->filter->($_) } @prereqs;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::PrerequisiteWalker - Iterates through distribution prerequisites

=head1 VERSION

version 0.065_03

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
