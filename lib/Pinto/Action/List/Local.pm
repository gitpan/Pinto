package Pinto::Action::List::Local;

# ABSTRACT: Action that lists only the local packages in a repository

use Moose;

extends 'Pinto::Action::List';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    for my $package ( $self->idxmgr()->local_packages() ) {
        print { $self->out() } $package->to_index_string();
    }

    return 0;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::List::Local - Action that lists only the local packages in a repository

=head1 VERSION

version 0.021

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
