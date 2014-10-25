# ABSTRACT: List the contents of a stack

package Pinto::Action::List;

use Moose;
use MooseX::Types::Moose qw(Undef HashRef Str Bool);

use Pinto::Types qw(Author StackName StackAll StackDefault);
use Pinto::Constants qw($PINTO_STACK_NAME_ALL);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.055'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | StackAll | StackDefault,
    default   => undef,
    coerce    => 1,
);


has pinned => (
    is     => 'ro',
    isa    => Bool,
);


has author => (
    is     => 'ro',
    isa    => Author,
    coerce => 1,
);


has packages => (
    is     => 'ro',
    isa    => Str,
);


has distributions => (
    is     => 'ro',
    isa    => Str,
);


has format => (
    is        => 'ro',
    isa       => Str,
    default   => "%m%s%y %-40n %12v  %a/%f",
    predicate => 'has_format',
    lazy      => 1,
);


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

    if (my $dist_name = $self->distributions) {
        $where->{'distribution.archive'} = { like => "%$dist_name%" };
    }

    if (my $author = $self->author) {
        $where->{'distribution.author'} = $author;
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

    if (defined $stk_name and $stk_name eq $PINTO_STACK_NAME_ALL) {
        # If listing all stacks, then include the stack name
        # in the listing, unless a custom format has been given
        $format = $self->has_format ? $self->format
                                    : "%m%s%y %-12k %-40n %12v  %p";
    }
    else{
        # Otherwise, list only the named stack, falling back to
        # the default stack if no stack was named at all.
        my $stack = $self->repos->get_stack(name => $stk_name);
        $where->{'stack.name'} = $stack->name;
        $format = $self->format;
    }

    ##################################################################
    # NOTE: The 'join' attribute on this next query should actually be
    # a 'prefetch' but that stopped working in DBIx::Class-0.08198.
    # See RT #78456 for discussion.  It seems to generate the right
    # SQL, but it doesn't actually populate the related objects from
    # the prefetched data.  Our other queries that use 'prefetch' seem
    # to work fine, so I'm not sure why this one fails.
    #
    # In the meantime, I've discovered (by trial-and-error) that this
    # version of the query seems to work, although it may require us
    # to make extra trips to the database to get the related objects
    # when we stringify the registration.

    my $attrs = { order_by => [ qw(package_name package_version distribution_path) ],
                  join     => ['stack', {package => 'distribution'}] };

    ################################################################

    my $rs = $self->repos->db->select_registrations($where, $attrs);

    while( my $registration = $rs->next ) {
        $self->say($registration->to_string($format));
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

version 0.055

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
