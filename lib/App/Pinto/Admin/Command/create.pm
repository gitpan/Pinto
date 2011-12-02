package App::Pinto::Admin::Command::create;

# ABSTRACT: create a new empty repository

use strict;
use warnings;

use Pinto::Creator;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.025_001'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw( create new ) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'devel'      => 'Include development releases in the repository index' ],
        [ 'noinit'     => 'Do not pull/update from VCS before each operation' ],
        [ 'source=s@'  => 'URL of repository for foreign distributions (repeatable)' ],
        [ 'store=s'    => 'Name of class that handles storage of your repository' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error('Arguments are not allowed') if @{ $args };

    return 1;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my $root_dir = $self->app->global_options()->{repos}
        or die 'Must specify a repository directory';    ## no critic qw(Carp)

    # Combine repeatable "source" options into one space-delimited "sources" option.
    # TODO: Use a config file format that allows multiple values per key (MVP perhaps?).
    $opts->{sources} = join ' ', @{ delete $opts->{source} } if defined $opts->{source};

    my $creator = Pinto::Creator->new( root_dir => $root_dir );
    $creator->create( %{$opts} );
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::create - create a new empty repository

=head1 VERSION

version 0.025_001

=head1 SYNOPSIS

  pinto-admin --repos=/some/dir create [OPTIONS]

=head1 DESCRIPTION

This command creates a new, empty repository.  If the target directory
does not exist, it will be created for you.  If it does already exist,
then it must be empty.  The new repository will contain empty index
files.  You can set the configuration parameters of the new repository
using the command line options listed below.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

=over 4

=item --devel

Instructs L<Pinto> to include development releases in the index.  A
development release is any archive that includes an underscore (_) in
the last component of the version number.

=item --noinit

Prevents L<Pinto> from pulling/updating the repository from the VCS
before all operations.  This is only relevant if you are using a
VCS-based storage mechanism.  This can speed up operations
considerably, but should only be used if you *know* that your working
copy is up-to-date and you are going to be the only actor touching the
Pinto repository within the VCS.

=item --store CLASS_NAME

The name of the class that will handle storage for your repository.
The default is L<Pinto::Store> which just stores files on the local
dist.  But you can also use a VCS-based store, such as
L<Pinto::Store::VCS::Svn> or L<Pinto::Store::VCS::Git>.  Each Store
has its own idiosyncrasies, so check the documentation of your Store
for specific details on its usage.

=item --source URL

The URL of a repository where foreign distributions will be pulled
from.  This is usually the URL of a CPAN mirror, and it defaults to
L<http://cpan.perl.org>.  But it could also be a L<CPAN::Mini> mirror,
or another L<Pinto> repository.

You can specify multiple repository URLs by repeating the C<--source>
option.  Repositories that appear earlier in the list have priority
over those that appear later.  See L<Pinto::Manual> for more
information about using multiple source repositories.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

