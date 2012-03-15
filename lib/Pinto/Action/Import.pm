package Pinto::Action::Import;

# ABSTRACT: Import a package (and its prerequisites) into the local repository

use version;

use Moose;
use MooseX::Types::Moose qw(Str Bool);

use Pinto::Types qw(Vers);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.033'; # VERSION

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

    my ($dist, $imported_flag) = $self->find_or_import( $wanted );
    return 0 if not $dist;

    $self->add_message( Pinto::Util::imported_dist_message($dist) )
        if $imported_flag;

    unless ( $self->norecurse() ) {
        my $archive = $dist->archive( $self->repos->root_dir() );
        my @imported_prereqs = $self->import_prerequisites($archive);
        $self->add_message( Pinto::Util::imported_prereq_dist_message( $_ ) ) for @imported_prereqs;
        $imported_flag += @imported_prereqs;
    }

    return $imported_flag;
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

version 0.033

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
