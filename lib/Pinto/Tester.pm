package Pinto::Tester;

# ABSTRACT: A class for testing a Pinto repository

use Moose;
use MooseX::NonMoose;
use MooseX::Types::Moose qw(ScalarRef HashRef);

use Carp;
use IO::String;
use Path::Class;

use Pinto;
use Pinto::Util;
use Pinto::Creator;
use Pinto::Types qw(Dir);

#------------------------------------------------------------------------------

our $VERSION = '0.031'; # VERSION

#------------------------------------------------------------------------------

extends 'Test::Builder::Module';

#------------------------------------------------------------------------------

has pinto_args => (
   is         => 'ro',
   isa        => HashRef,
   default    => sub { {} },
   auto_deref => 1,
);


has creator_args => (
   is         => 'ro',
   isa        => HashRef,
   default    => sub { {} },
   auto_deref => 1,
);


has pinto => (
    is       => 'ro',
    isa      => 'Pinto',
    builder  => '_build_pinto',
    lazy     => 1,
);


has root => (
   is       => 'ro',
   isa      => Dir,
   default  => sub { dir( File::Temp::tempdir(CLEANUP => 1) ) },
);


has buffer => (
   is         => 'ro',
   isa        => ScalarRef,
   default    => sub { \my $buffer },
   writer     => '_set_buffer',
);


has tb => (
   is       => 'ro',
   isa      => 'Test::Builder',
   init_arg => undef,
   default  => => sub { __PACKAGE__->builder() },
);

#------------------------------------------------------------------------------

sub _build_pinto {
    my ($self) = @_;

    my $creator = Pinto::Creator->new( root => $self->root() );
    $creator->create( $self->creator_args() );

    my %defaults = ( out => $self->buffer(), verbose => 3, root => $self->root() );

    return Pinto->new(%defaults, $self->pinto_args());
}
#------------------------------------------------------------------------------

sub bufferstr {
    my ($self)  = @_;

    return ${ $self->buffer() };
}

#------------------------------------------------------------------------------

sub reset_buffer {
    my ($self, $new_buffer) = @_;

    $new_buffer ||= \my $buffer;
    my $io = IO::String->new( ${$new_buffer} );
    $self->pinto->logger->{out} = $io; # Hack!
    $self->_set_buffer($new_buffer);

    return $self;
}

#------------------------------------------------------------------------------

sub path_exists_ok {
    my ($self, $path, $name) = @_;

    $path = file( $self->root(), @{$path} );
    $name ||= "Path $path exists";

    $self->tb->ok(-e $path, $name);

    return;
}

#------------------------------------------------------------------------------

sub path_not_exists_ok {
    my ($self, $path, $name) = @_;

    $path = file( $self->root(), @{$path} );
    $name ||= "Path $path does not exist";

    $self->tb->ok(! -e $path, $name);

    return;
}

#------------------------------------------------------------------------------

sub package_loaded_ok {
    my ($self, $pkg_spec, $latest) = @_;

    my ($author, $dist_file, $pkg_name, $pkg_ver) = parse_pkg_spec($pkg_spec);

    my $author_dir = Pinto::Util::author_dir($author);
    my $dist_path = $author_dir->file($dist_file)->as_foreign('Unix');

    my $attrs = { prefetch  => 'distribution' };
    my $where = { name => $pkg_name, 'distribution.path' => $dist_path };
    my $pkg = $self->pinto->repos->db->select_packages($where, $attrs)->single();
    return $self->tb->ok(0, "$pkg_spec is not loaded at all") if not $pkg;

    $self->tb->ok(1, "$pkg_spec is loaded");
    $self->tb->is_eq($pkg->version(), $pkg_ver, "$pkg_name has correct version");

    my $archive = $pkg->distribution->archive( $self->root() );
    $self->tb->ok(-e $archive, "Archive $archive exists");

    $self->tb->is_eq( $pkg->is_latest(), 1, "$pkg_spec is latest" )
        if $latest;

    $self->tb->is_eq( $pkg->is_latest(), undef, "$pkg_spec is not latest" )
        if not $latest;

    return;
}

#------------------------------------------------------------------------------

sub package_not_loaded_ok {
    my ($self, $pkg_spec) = @_;

    my ($author, $dist_file, $pkg_name, $pkg_ver) = parse_pkg_spec($pkg_spec);

    my $author_dir = Pinto::Util::author_dir($author);
    my $dist_path = $author_dir->file($dist_file)->as_foreign('Unix');
    my $archive   = $self->root()->file(qw(authors id), $author_dir, $dist_file);

    my $attrs = { prefetch  => 'distribution' };
    my $where = { name => $pkg_name, 'distribution.path' => $dist_path };
    my $pkg = $self->pinto->repos->select_packages($where, $attrs)->single();

    $self->tb->ok(!$pkg, "$pkg_spec is still loaded");

    $self->tb->ok(! -e $archive, "Archive $archive still exists");

    return;
}

#------------------------------------------------------------------------------

sub result_ok {
    my ($self, $result) = @_;

    $self->tb->ok( $result->is_success(), 'Result was succesful' )
        || $self->tb->diag( "Diagnostics: " . $result->to_string() );

    return;
}

#------------------------------------------------------------------------------

sub result_not_ok {
    my ($self, $result) = @_;

    $self->tb->ok( !$result->is_success(), 'Result was not succesful' );

    return;
}

#------------------------------------------------------------------------------

sub repository_empty_ok {
    my ($self) = @_;

    my @dists = $self->pinto->repos->select_distributions()->all();
    $self->tb->is_eq(scalar @dists, 0, 'Database has no distributions');

    my @pkgs = $self->pinto->repos->select_packages()->all();
    $self->tb->is_eq(scalar @pkgs, 0, 'Database has no packages');

    my $dir = dir( $self->root(), qw(authors id) );
    $self->tb->ok(! -e $dir, 'Repository has no archives');

    return;
}

#------------------------------------------------------------------------------

sub log_like {
    my ($self, $rx, $name) = @_;

    $name ||= 'Log output matches';

    $self->tb->like( $self->bufferstr(), $rx, $name );

    return;
}

#------------------------------------------------------------------------------

sub log_unlike {
    my ($self, $rx, $name) = @_;

    $name ||= 'Log output does not match';

    $self->tb->unlike( $self->bufferstr(), $rx, $name );

    return;
}

#------------------------------------------------------------------------------

sub parse_pkg_spec {
    my ($spec) = @_;

    # Looks like "AUTHOR/Foo-1.2.tar.gz/Foo::Bar-1.2"
    $spec =~ m{ ^ ([^/]+) / ([^/]+) / ([^-]+) - (.+) $ }mx
        or croak "Could not parse pkg spec: $spec";

    # TODO: use sexy named captures instead
    my ($author, $dist_file, $pkg_name, $pkg_ver) = ($1, $2, $3, $4);

    return ($author, $dist_file, $pkg_name, $pkg_ver);
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Tester - A class for testing a Pinto repository

=head1 VERSION

version 0.031

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
