# ABSTRACT: Store a Pinto repository on the local filesystem

package Pinto::Store::File;

use Moose;

use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.052'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends qw( Pinto::Store );

#------------------------------------------------------------------------------
# Methods

augment remove_path => sub {
    my ($self, %args) = @_;

    my $path = $args{path};
    $path->remove or throw "Failed to remove path $path: $!";

    while (my $dir = $path->parent) {
        last if $dir->children;
        $self->debug("Removing empty directory $dir");
        $dir->remove or throw "Failed to remove directory $dir: $!";
        $path = $dir;
    }

    return $self;
};

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store::File - Store a Pinto repository on the local filesystem

=head1 VERSION

version 0.052

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
