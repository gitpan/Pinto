package Pinto::Action::Add;

# ABSTRACT: An action to add one archive to the repository

use Moose;

use Carp;
use File::Copy;
use Dist::Metadata;

use Pinto::Util;
use Pinto::IndexManager;
use Pinto::Types qw(File);

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.006'; # VERSION

#------------------------------------------------------------------------------
# Attrbutes

has file => (
    is       => 'ro',
    isa      => File,
    required => 1,
    coerce   => 1,
);

#------------------------------------------------------------------------------
# Roles

with qw( Pinto::Role::Authored );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $local  = $self->config->local();
    my $author = $self->author();

    my $file   = $self->file();
    my $base   = $file->basename();

    # Refactor to sub
    croak "$file does not exist"  if not -e $file;
    croak "$file is not readable" if not -r $file;
    croak "$file is not a file"   if not -f $file;

    # Refactor to sub
    my $idxmgr = $self->idxmgr();
    if ( my $existing = $idxmgr->find_file(author => $author, file => $file) ) {
        croak "Archive $base already exists as $existing";
    }

    # Refactor to sub
    # Dist::Metadata will croak for us if $file is whack!
    my $distmeta = Dist::Metadata->new(file => $file->stringify());
    my $provides = $distmeta->package_versions();
    return 0 if not %{ $provides };

    # Refactor to sub
    my @conflicts = ();
    for my $package_name (sort keys %{ $provides }) {
        if ( my $orig_author = $idxmgr->local_author_of(package => $package_name) ) {
            push @conflicts, "Package $package_name is already owned by $orig_author\n"
                if $orig_author ne $author;
        }
    }
    die @conflicts if @conflicts;

    # Refactor to sub
    my @packages = ();
    for my $package_name (sort keys %{ $provides }) {

        my $version = $provides->{$package_name} || 'undef';
        $self->logger->log("Adding package $package_name $version");
        push @packages, Pinto::Package->new( name    => $package_name,
                                             file    => $file,
                                             version => $version,
                                             author  => $author );
    }


    $self->idxmgr()->add_local_packages(@packages);
    my $destination_dir = Pinto::Util::directory_for_author($local, qw(authors id), $author);
    $destination_dir->mkpath();    # TODO: log & error check
    copy($file, $destination_dir); # TODO: log & error check

    my $message = Pinto::Util::format_message("Added archive $base providing:", sort keys %{$provides});
    $self->_set_message($message);

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Add - An action to add one archive to the repository

=head1 VERSION

version 0.006

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
