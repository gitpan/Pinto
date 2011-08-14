package Pinto::Action::Verify;

# ABSTRACT: An action to verify all files are present in the repository

use Moose;
use Moose::Autobox;

use Pinto::Util;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.010'; # VERSION

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $local = $self->config()->local();
    my $dists = $self->idxmgr->master_index->distributions->values();
    my $sorter = sub {$_[0]->location() cmp $_[1]->location};

    # TODO: accept an alternative filehandle for output.
    # TODO: force log_level to quiet when running this action.

    for my $dist ( $dists->sort( $sorter )->flatten() ) {
        my $file = $dist->path($local);
        print "Missing distribution $file\n" if not -e $file;
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

Pinto::Action::Verify - An action to verify all files are present in the repository

=head1 VERSION

version 0.010

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
