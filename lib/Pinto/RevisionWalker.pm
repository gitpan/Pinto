# ABSTRACT: Iterates through distribution prerequisites

package Pinto::RevisionWalker;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(ArrayRef);
use MooseX::MarkAsMethods (autoclean => 1);

#------------------------------------------------------------------------------

our $VERSION = '0.067'; # VERSION

#------------------------------------------------------------------------------
# TODO: Rethink this API.  Do we need start?  Can we just use queue?  What
# about filtering, or walking forward?  Sort chronolobical or topological?

has start => (
	is       => 'ro',
	isa      => 'Pinto::Schema::Result::Revision',
	required => 1,
);


has queue => (
    isa      => ArrayRef,
    traits   => [ qw(Array) ],
    handles  => {enqueue => 'push', dequeue => 'shift'},
    default  => sub { [ $_[0]->start ] },
    lazy     => 1,
);

#------------------------------------------------------------------------------

sub next {
  my ($self) = @_;

    my $next = $self->dequeue;

    return if not $next;
    return if $next->is_root;

    $self->enqueue($next->parents);

    return $next;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::RevisionWalker - Iterates through distribution prerequisites

=head1 VERSION

version 0.067

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
