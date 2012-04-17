# ABSTRACT: List the contents of a repository

package Pinto::Action::List;

use Moose;

use MooseX::Types::Moose qw(HashRef);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.038'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::List );

#------------------------------------------------------------------------------

has where => (
    is      => 'ro',
    isa     => HashRef,
    builder => '_build_where',
    lazy    => 1,
);

#------------------------------------------------------------------------------

sub _build_where {
    my ($self) = @_;

    my $where = {};

    my $pkg_name = $self->packages();
    $where->{name} = { like => "%$pkg_name%" } if $pkg_name;

    my $dist_path = $self->distributions();
    $where->{path} = { like => "%$dist_path%" } if $dist_path;

    my $index = $self->index();
    $where->{is_latest} = $index ? 1 : undef if defined $index;

    my $pinned = $self->pinned();
    $where->{is_pinned} = $pinned ? 1 : undef if defined $pinned;

    return $where;
}


#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $where = $self->where();

    my $attrs = { order_by => [ qw(name version path) ],
                  prefetch => 'distribution' };

    my $rs = $self->repos->db->select_packages($where, $attrs);

    my $format = $self->format();
    while( my $package = $rs->next() ) {
        print { $self->out() } $package->to_formatted_string($format);
    }

    return 0;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::List - List the contents of a repository

=head1 VERSION

version 0.038

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
