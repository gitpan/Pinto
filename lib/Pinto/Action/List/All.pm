package Pinto::Action::List::All;

# ABSTRACT: Action that lists all the packages in a repository

use Moose;

extends 'Pinto::Action::List';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.022'; # VERSION

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    for my $package ( $self->idxmgr()->all_packages() ) {
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

Pinto::Action::List::All - Action that lists all the packages in a repository

=head1 VERSION

version 0.022

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
