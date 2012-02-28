package Pinto::Action::Unpin;

# ABSTRACT: Loosen a package that has been pinned

use Moose;
use MooseX::Types::Moose qw(Str);

use Pinto::Types qw(Vers);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.031'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has package => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $name  =  $self->package();
    my $where = { name => $name, is_pinned => 1 };
    my $pkg   = $self->repos->select_packages($where)->first();

    if (not $pkg) {
        $self->whine("Package $name does not exist in the repository, or is not pinned");
        return 0;
    }

    $self->info("Unpinning package $pkg");

    $pkg->is_pinned(undef);
    $pkg->update();
    my $latest = $self->repos->db->mark_latest($pkg);

    $self->add_message("Unpinned package $name. Latest is now $latest");

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Unpin - Loosen a package that has been pinned

=head1 VERSION

version 0.031

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
