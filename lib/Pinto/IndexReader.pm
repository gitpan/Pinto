# ABSTRACT: The package index of a repository

package Pinto::IndexReader;

use Moose;
use MooseX::Types::Moose qw(HashRef);
use MooseX::MarkAsMethods (autoclean => 1);

use IO::Zlib;

use Pinto::Types qw(File);
use Pinto::Util qw(throw);

#------------------------------------------------------------------------

our $VERSION = '0.09992_02'; # VERSION

#------------------------------------------------------------------------

has index_file => (
    is         => 'ro',
    isa        => File,
    required   => 1,
);

has packages => (
    is        => 'ro',
    isa       => HashRef,
    builder   => '_build_packages',
    lazy      => 1,
);

#------------------------------------------------------------------------------

sub _build_packages {
    my ($self) = @_;

    my $file = $self->index_file->stringify;
    my $fh = IO::Zlib->new($file, 'rb') or throw "Failed to open index file $file: $!";
    my $index_data = $self->__read_index($fh);
    close $fh;

    return $index_data;
}

#------------------------------------------------------------------------------

sub __read_index {
    my ($self, $fh) = @_;

    my $inheader  = 1;
    my $packages  = {};

    while (<$fh>) {

        if ($inheader) {
            $inheader = 0 if not m/ \S /x;
            next;
        }

        chomp;
        my ($package, $version, $path) = split;
        $packages->{$package} = {name => $package, version => $version, path => $path};
    }

    return $packages
}

#------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------
1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Nikolay Martynov Oleg Gashev Steffen Schwigon
Tommy Stanton Wolfgang Boris Kinkeldei Yanick Champoux brian d foy hesco
popl Däppen Cory G Watson David Steinbrunner Glenn

=head1 NAME

Pinto::IndexReader - The package index of a repository

=head1 VERSION

version 0.09992_02

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
