package Pinto::Role::Authored;

# ABSTRACT: Something that has an author

use Moose::Role;
use Pinto::Types qw(AuthorID);

use Carp;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.003'; # VERSION

#-----------------------------------------------------------------------------

requires 'config';

has author => (
    is         => 'ro',
    isa        => AuthorID,
    coerce     => 1,
    lazy_build => 1,
);

sub _build_author {
    my ($self) = @_;
    return $self->config->author()
      or croak 'author attribute is required';
}



#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Authored - Something that has an author

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
