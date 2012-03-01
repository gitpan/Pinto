package Pinto::Action::Verify;

# ABSTRACT: Verify all distributions are present in the repository

use Moose;

use Pinto::Util;
use Pinto::Types qw(IO);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.032'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------
# Attributes

has out => (
    is       => 'ro',
    isa      => IO,
    coerce   => 1,
    default  => sub { [fileno(STDOUT), '>'] },
);

#------------------------------------------------------------------------------
# Methods

sub execute {
    my ($self) = @_;

    my $rs    = $self->repos->select_distributions();

    while ( my $dist = $rs->next() ) {
        my $archive = $dist->archive( $self->repos->root_dir() );
        print { $self->out } "Missing distribution $archive\n" if not -e $archive;
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

Pinto::Action::Verify - Verify all distributions are present in the repository

=head1 VERSION

version 0.032

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
