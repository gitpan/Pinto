package Pinto::Config;

# ABSTRACT: Internal configuration for a Pinto repository

use Moose;

use MooseX::Configuration;

use MooseX::Types::Moose qw(Str Bool Int);
use Pinto::Types 0.017 qw(URI Dir);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.018'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has repos   => (
    is        => 'ro',
    isa       => Dir,
    required  => 1,
    coerce    => 1,
);


has source  => (
    is        => 'ro',
    isa       => URI,
    key       => 'source',
    default   => 'http://cpan.perl.org',
    coerce    => 1,
    documentation => 'URL of a CPAN mirror (or Pinto repository) where foreign dists will be pulled from',
);


has nocleanup => (
    is        => 'ro',
    isa       => Bool,
    key       => 'nocleanup',
    default   => 0,
    documentation => 'If true, then Pinto will not delete older distributions when newer versions are added',
);


has noclobber => (
    is        => 'ro',
    isa       => Bool,
    key       => 'noclobber',
    default   => 0,
    documentation => 'If true, then Pinto will not clobber existing packages when adding new ones',
);


has noinit   => (
    is       => 'ro',
    isa      => Bool,
    key      => 'noinit',
    default  => 0,
    documentation => 'If true, then Pinto will not update/pull the repository from VCS before each action',
);


has store => (
    is        => 'ro',
    isa       => Str,
    key       => 'store',
    default   => 'Pinto::Store',
    documentation => 'Name of the class that will handle storage of your repository',
);


has svn_trunk => (
    is        => 'ro',
    isa       => Str,
    key       => 'trunk',
    section   => 'Pinto::Store::VCS::Svn',
);


has svn_tag => (
    is        => 'ro',
    isa       => Str,
    key       => 'tag',
    section   => 'Pinto::Store::VCS::Svn',
);

#------------------------------------------------------------------------------
# Builders

sub _build_config_file {
    my ($self) = @_;

    my $repos = $self->repos();

    my $config_file = Path::Class::file($repos, qw(config pinto.ini) );

    return -e $config_file ? $config_file : ();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Config - Internal configuration for a Pinto repository

=head1 VERSION

version 0.018

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

