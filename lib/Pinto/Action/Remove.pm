package Pinto::Action::Remove;

# ABSTRACT: An action to remove packages from the repository

use Moose;
use MooseX::Types::Moose qw( Str );

use Carp;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.003'; # VERSION

#------------------------------------------------------------------------------

has package  => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Authored );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $pkg    = $self->package();
    my $author = $self->author();

    my $idxmgr = $self->idxmgr();
    my $orig_author = $idxmgr->local_author_of(package => $pkg);

    croak "You are $author, but only $orig_author can remove $pkg"
        if defined $orig_author and $author ne $orig_author;

    if (my @removed = $idxmgr->remove_local_package(package => $pkg)) {
        my $message = Pinto::Util::format_message("Removed packages:", sort @removed);
        $self->_set_message($message);
        return 1;
    }

    $self->logger()->warn("Package $pkg is not in the index");
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Remove - An action to remove packages from the repository

=head1 VERSION

version 0.003

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
