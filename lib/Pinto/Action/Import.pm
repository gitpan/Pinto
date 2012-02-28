package Pinto::Action::Import;

# ABSTRACT: Import a package (and its prerequisites) into the local repository

use version;

use Moose;
use MooseX::Types::Moose qw(Str Bool);

use Pinto::Types qw(Vers);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.031'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------
# Attributes

has package_name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has minimum_version => (
    is      => 'ro',
    isa     => Vers,
    default => sub { version->parse(0) },
    coerce  => 1,
);


has norecurse => (
   is      => 'ro',
   isa     => Bool,
   default => 0,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::PackageImporter );

#------------------------------------------------------------------------------

# TODO: Allow the import target to be specified as a package/version,
# dist path, or a particular URL.  Then do the right thing for each.

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $wanted = { name    => $self->package_name(),
                   version => $self->minimum_version() };

    my $dist = $self->find_or_import( $wanted );
    return 0 if not $dist;

    my $archive = $dist->archive( $self->repos->root_dir() );
    $self->import_prerequisites($archive) unless $self->norecurse();

    # HACK: We need to return true only if we actually imported
    # something.  If we didn't import anything (i.e. couldn't find
    # anything or we already have everything) then we must return
    # false so that we don't cause an unnecessary VCS commit.
    # Checking the message count is a sleazy way of figuring out how
    # many distributions we actually imported.  TODO: consider using a
    # counter attribute, or refactor _find_or_import so that it can
    # tell you whether or not it actually imported something.

    my @msgs = $self->messages();
    return scalar @msgs;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Import - Import a package (and its prerequisites) into the local repository

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
