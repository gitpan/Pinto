package Pinto::Action::Pin;

# ABSTRACT: Force a package into the index

use Moose;
use MooseX::Types::Moose qw(Str);

use Pinto::Types qw(Vers);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.030'; # VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has package => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has version => (
    is        => 'ro',
    isa       => Vers,
    predicate => 'has_version',
    coerce    => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $pkg = $self->_get_package() or return 0;

    $self->whine("Package $pkg is already pinned")
        and return 0 if $pkg->is_pinned();

    $self->whine("This repository does not permit pinning developer packages")
        and return 0 if $pkg->distribution->is_devel() and not $self->config->devel();

    $self->_do_pin($pkg);

    return 1;
}

#------------------------------------------------------------------------------

sub _get_package {
    my ($self) = @_;

    my $where           = { name => $self->package() };
    $where->{version}   = $self->version() if $self->has_version();
    $where->{is_latest} = 1 if not $self->has_version();

    my $pkg_rs = $self->repos->select_packages($where);
    my $pkg_count = $pkg_rs->count();

    my $vname_suffix = $self->has_version() ? '-' . $self->version() : '';
    my $pkg_vname = $self->package() . $vname_suffix;

    if (not $pkg_count) {
        $self->whine("Package $pkg_vname does not exist in the repository");
        return;
    }
    elsif ( $pkg_count > 1) {
        # TODO: Need to handle this better.  Maybe specify precise distribution?
        $self->whine("Repository has multiple copies of package $pkg_vname");
        return;
    }

    # At this point, we know there is only one record
    my $pkg = $pkg_rs->first();

    return $pkg;
}

#------------------------------------------------------------------------------

sub _do_pin {
    my ($self, $pkg) = @_;

    $self->info("Pinning package $pkg");

    # Only one version of a package can be pinned at a time.
    # So first, we unpin all the packages with that name...
    my $where   = { name => $pkg->name() };
    my @sisters = $self->repos->select_packages( $where )->all();
    $_->is_pinned(undef) for @sisters;
    $_->update() for @sisters;

    # Then pin the particular package we want...
    $pkg->is_pinned(1);
    $pkg->update();

    # Finally, remark the latest version of the package
    $self->repos->db->mark_latest($pkg);

    my $name = $pkg->name();
    $self->add_message("Pinned package $name. Latest is now $pkg");

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Pin - Force a package into the index

=head1 VERSION

version 0.030

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
