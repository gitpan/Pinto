# ABSTRACT: Internal configuration for a Pinto repository

package Pinto::Config;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Str Bool Int ArrayRef);
use MooseX::MarkAsMethods ( autoclean => 1 );
use MooseX::Configuration;
use MooseX::Aliases;

use URI;

use Pinto::Constants qw(@PINTO_DEFAULT_SOURCE_URIS);
use Pinto::Types qw(Dir File Username PerlVersion);
use Pinto::Util qw(current_username current_time_offset);

#------------------------------------------------------------------------------

our $VERSION = '0.09996'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has root => (
    is       => 'ro',
    isa      => Dir,
    alias    => 'root_dir',
    required => 1,
    coerce   => 1,
);

has username => (
    is      => 'ro',
    isa     => Username,
    default => sub { return current_username },
    lazy    => 1,
);

has time_offset => (
    is      => 'ro',
    isa     => Int,
    default => sub { return current_time_offset },
    lazy    => 1,
);

has stacks_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->root_dir->subdir('stacks') },
    lazy     => 1,
);

has authors_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->root_dir->subdir('authors') },
    lazy     => 1,
);

has authors_id_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->authors_dir->subdir('id') },
    lazy     => 1,
);

has modules_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->root_dir->subdir('modules') },
    lazy     => 1,
);

has mailrc_file => (
    is       => 'ro',
    isa      => File,
    init_arg => undef,
    default  => sub { return $_[0]->authors_dir->file('01mailrc.txt.gz') },
    lazy     => 1,
);

has db_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->pinto_dir->subdir('db') },
    lazy     => 1,
);

has db_file => (
    is       => 'ro',
    isa      => File,
    init_arg => undef,
    default  => sub { return $_[0]->db_dir->file('pinto.db') },
    lazy     => 1,
);

has pinto_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->root_dir->subdir('.pinto') },
    lazy     => 1,
);

has config_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->pinto_dir->subdir('config') },
    lazy     => 1,
);

has cache_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->pinto_dir->subdir('cache') },
    lazy     => 1,
);

has log_dir => (
    is       => 'ro',
    isa      => Dir,
    init_arg => undef,
    default  => sub { return $_[0]->pinto_dir->subdir('log') },
    lazy     => 1,
);

has version_file => (
    is       => 'ro',
    isa      => File,
    init_arg => undef,
    default  => sub { return $_[0]->pinto_dir->file('version') },
    lazy     => 1,
);

has basename => (
    is       => 'ro',
    isa      => Str,
    init_arg => undef,
    default  => 'pinto.ini',
);

#------------------------------------------------------------------------------
# Actual configurable attributes

has sources => (
    is            => 'ro',
    isa           => Str,
    key           => 'sources',
    default       => "@PINTO_DEFAULT_SOURCE_URIS",
    documentation => 'URIs of upstream repositories (space delimited)',
);

has target_perl_version => (
    is            => 'ro',
    isa           => PerlVersion,
    key           => 'target_perl_version',
    documentation => 'Default target perl version for new stacks',
    default       => $], # Note: $PERL_VERSION is broken on old perls
    coerce        => 1,
);

has recurse => (
    is            => 'ro',
    isa           => Bool,
    key           => 'recurse',
    documentation => 'Default recursive behavior',
    default       => 1,          
);

has intermingle => (
    is            => 'ro',
    isa           => Bool,
    key           => 'intermingle',
    documentation => 'Allow stacks to intermingle distributions',
    default       => 0,          
);

#------------------------------------------------------------------------------

sub _build_config_file {
    my ($self) = @_;

    my $config_file = $self->config_dir->file( $self->basename );

    return -e $config_file ? $config_file : ();
}

#------------------------------------------------------------------------------

sub sources_list {
    my ($self) = @_;

    # Some folks tend to put quotes around multi-value configuration
    # parameters, even though they shouldn't.  Be kind and remove them.
    my $sources = $self->sources;
    $sources =~ s/ ['"] //gx;

    return map { URI->new($_) } split m{ \s+ }mx, $sources;
}

#------------------------------------------------------------------------------

sub directories {
    my ($self) = @_;

    return ( $self->root_dir, $self->config_dir, $self->cache_dir, 
             $self->authors_dir, $self->log_dir, $self->db_dir );
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Config - Internal configuration for a Pinto repository

=head1 VERSION

version 0.09996

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
