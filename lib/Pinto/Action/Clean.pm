package Pinto::Action::Clean;

# ABSTRACT: An action to remove cruft from the repository

use Moose;

use File::Find;
use Path::Class;

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.008'; # VERSION

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $local      = $self->config()->local();
    my $search_dir = Path::Class::dir($local, qw(authors id));
    return 0 if not -e $search_dir;

    my @removed = ();
    my $wanted = $self->_make_callback($search_dir, \@removed);
    File::Find::find($wanted, $search_dir);
    return 0 if not @removed;

    $self->add_message( "Removed unindexed distribution $_" ) for @removed;

    return 1;
};

#------------------------------------------------------------------------------

sub _make_callback {
    my ($self, $search_dir, $deleted) = @_;

    return sub {

        if ( Pinto::Util::is_source_control_file($_) ) {
            $File::Find::prune = 1;
            return;
        }

        return if not -f $File::Find::name;

        my $file = file($File::Find::name);
        my $location  = $file->relative($search_dir)->as_foreign('Unix');
        return if $self->idxmgr->master_index->distributions->{$location};

        $self->store->remove(file => $file);
        push @{ $deleted }, $location;
    };
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Clean - An action to remove cruft from the repository

=head1 VERSION

version 0.008

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
