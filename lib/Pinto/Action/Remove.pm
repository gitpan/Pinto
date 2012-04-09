# ABSTRACT: Remove one distribution from the repository

package Pinto::Action::Remove;

use Moose;

use Pinto::Util;
use Pinto::Exceptions qw(throw_error);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.036'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Remove );

#------------------------------------------------------------------------------


sub execute {
    my ($self) = @_;

    my $path    = $self->path();
    my $author  = $self->author();

    $path = $path =~ m{/}mx ? $path
                            : Pinto::Util::author_dir($author)->file($path)->as_foreign('Unix');

    my $where = {path => $path};
    my $dist  = $self->repos->select_distributions( $where )->single();
    throw_error "Distribution $path does not exist" if not $dist;

    # Must call accessor to ensure the package objects are attached
    # to the dist object before we delete.  Otherwise, we can't log
    # which packages were deleted, because they'll already be gone.
    my @pkgs = $dist->packages();
    my $count = @pkgs;

    $self->notice("Removing distribution $dist with $count packages");

    $self->repos->remove_distribution($dist);

    $self->add_message( Pinto::Util::removed_dist_message($dist) );

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Remove - Remove one distribution from the repository

=head1 VERSION

version 0.036

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
