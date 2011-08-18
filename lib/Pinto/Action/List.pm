package Pinto::Action::List;

# ABSTRACT: An action that lists the contents of a repository

use Moose;
use Pinto::Types qw(IO);

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.015'; # VERSION

#------------------------------------------------------------------------------
# TODO: default this to STDOUT.  Not sure how to to do this with an IO type.

has out => (
    is      => 'ro',
    isa     => IO,
    coerce  => 1,
    default => sub { [fileno(STDOUT), '>'] },
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    # TODO: force log_level to quiet when running this action.

    for my $package ( $self->idxmgr()->all_packages() ) {
        print { $self->out() } $package->to_index_string();
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

Pinto::Action::List - An action that lists the contents of a repository

=head1 VERSION

version 0.015

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
