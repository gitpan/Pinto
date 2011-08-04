package Pinto::Config;

# ABSTRACT: User configuration for Pinto

use Moose;
use MooseX::Configuration;

use MooseX::Types::Moose qw(Str Bool Int);
use Pinto::Types qw(AuthorID URI Dir);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.005'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has 'local'   => (
    is        => 'ro',
    isa       => Dir,
    key       => 'local',
    required  => 1,
    coerce    => 1,
);


has 'mirror'  => (
    is        => 'ro',
    isa       => URI,
    key       => 'mirror',
    default   => 'http://cpan.perl.org',
    coerce    => 1,
);


has 'author'  => (
    is        => 'ro',
    isa       => AuthorID,
    key       => 'author',
    coerce    => 1,
);


has 'nocleanup' => (
    is        => 'ro',
    isa       => Bool,
    key       => 'nocleanup',
    default   => 0,
);


has 'force'    => (
    is        => 'ro',
    isa       => Bool,
    key       => 'force',
    default   => 0,
);


has 'store' => (
    is        => 'ro',
    isa       => Str,
    key       => 'store',
    default   => 'Pinto::Store',
);


has 'nocommit' => (
    is       => 'ro',
    isa      => Bool,
    key      => 'nocommit',
    default  => 0,
);


has 'quiet'  => (
    is       => 'ro',
    isa      => Bool,
    key      => 'quiet',
    default  => 0,
);


has 'verbose' => (
    is          => 'ro',
    isa         => Int,
    key         => 'verbose',
    default     => 0,
);


has 'svn_trunk' => (
    is          => 'ro',
    isa         => Str,
    key         => 'trunk',
    section     => 'Pinto::Store::Svn',
);


has 'svn_tag' => (
    is          => 'ro',
    isa         => Str,
    key         => 'tag',
    section     => 'Pinto::Store::Svn',
);

#------------------------------------------------------------------------------
# Override builder

sub _build_config_file {

    require File::HomeDir;
    require Path::Class;

    # TODO: look at $ENV{PERL_PINTO} first.
    return Path::Class::file( File::HomeDir->my_home(), qw(.pinto config.ini) );
}

#------------------------------------------------------------------------------

__PACKAGE__->meta()->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Config - User configuration for Pinto

=head1 VERSION

version 0.005

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

