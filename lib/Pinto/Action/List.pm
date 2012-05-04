# ABSTRACT: List the contents of a stack

package Pinto::Action::List;

use Moose;
use MooseX::Types::Moose qw(HashRef);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_002'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::List );

#------------------------------------------------------------------------------

has where => (
    is       => 'ro',
    isa      => HashRef,
    builder  => '_build_where',
    lazy     => 1,
);

#------------------------------------------------------------------------------

sub _build_where {
    my ($self) = @_;

    my $where = {};

    if (my $pkg_name = $self->packages) {
        $where->{'package.name'} = { like => "%$pkg_name%" }
    }

    if (my $dist_path = $self->distributions) {
        $where->{'package.distribution.path'} = { like => "%$dist_path%" };
    }

    if (my $pinned = $self->pinned) {
        $where->{is_pinned} = 1;
    }

    return $where;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $where    = $self->where;
    my $stk_name = $self->stack;
    my $format;

    if (defined $stk_name and $stk_name eq '@') {
        # If listing all stacks, then include the stack name
        # in the listing, unless a custom format has been given
        $format = $self->has_format ? $self->format
                                    : "%m%s%y %-12k %-40n %12v  %p\n";
    }
    else{
        # Otherwise, list only the named stack, falling back to
        # the default stack if no stack was named at all.
        my $stack = $self->repos->get_stack(name => $stk_name);
        $where->{'stack.name'} = $stack->name;
        $format = $self->format;
    }

    my $attrs = { order_by => [ qw(me.package_name me.package_version me.distribution_path) ],
                  prefetch => [ 'stack', {'package' => 'distribution'} ] };

    my $rs = $self->repos->db->select_registrations($where, $attrs);

    while( my $registration = $rs->next ) {
        print { $self->out } $registration->to_string($format);
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

Pinto::Action::List - List the contents of a stack

=head1 VERSION

version 0.040_002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
