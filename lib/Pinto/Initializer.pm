# ABSTRACT: Initializes a new Pinto repository

package Pinto::Initializer;

use Moose;

use autodie;

use PerlIO::gzip;
use Path::Class;


use Pinto::Database;
use Pinto::Repository;
use Pinto::Util qw(current_user);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.063'; # VERSION

#------------------------------------------------------------------------------

with qw( Pinto::Role::Configurable
         Pinto::Role::PathMaker );

#------------------------------------------------------------------------------

# TODO: Can we use proper Moose attributes here, rather than passing a big
# hash of attributes to the init() method.  I seem to remember that I needed
# to do this so I would have something to give to $config->write.  But I'm
# not convinced this was the right solution.  It would probably be better
# to just put all the config attributes into repository props anyway.

#------------------------------------------------------------------------------


sub init {
    my ($self, %args) = @_;

    # Sanity checks
    my $root_dir = $self->config->root_dir();
    die "Directory $root_dir must be empty to create a repository there\n"
        if -e $root_dir and $root_dir->children();

    # Create repos root directory
    $self->mkpath($root_dir)
        if not -e $root_dir;

    # Create config dir
    my $config_dir = $self->config->config_dir();
    $self->mkpath($config_dir);

    # Write config file
    my $config_file = $config_dir->file( $self->config->basename() );
    $self->config->write_config_file( file => $config_file, values => \%args );

    # Create modules dir
    my $modules_dir = $self->config->modules_dir();
    $self->mkpath($modules_dir);

    # Create cache dir
    my $cache_dir = $self->config->cache_dir();
    $self->mkpath($cache_dir);

    # Set up database
    $self->_create_db();

    # Write modlist
    $self->_write_modlist();

    # Create authors dir
    my $authors_dir = $self->config->authors_dir();
    $self->mkpath($authors_dir);

    # Write authors index
    $self->_write_mailrc;

    # Create the inital stack, if needed
    $self->_create_stack(name => $args{stack}) unless $args{bare};

    # Log message for posterity
    $self->notice("Created new repository at directory $root_dir");

    return $self;
}

#------------------------------------------------------------------------------


sub _write_modlist {
    my ($self) = @_;

    my $modlist_file = $self->config->modlist_file;
    open my $fh, '>:gzip', $modlist_file;
    print {$fh} $self->_modlist_data();
    close $fh;

    return $modlist_file;

}

#------------------------------------------------------------------------------

sub _write_mailrc {
    my ($self) = @_;

    my $mailrc_file = $self->config->mailrc_file;
    open my $fh, '>:gzip', $mailrc_file;
    print {$fh} '';
    close $fh;

    return $mailrc_file;
}

#------------------------------------------------------------------------------

sub _modlist_data {

    my $template = <<'END_MODLIST';
File:        03modlist.data
Description: This a placeholder for CPAN.pm
Modcount:    0
Written-By:  Id: %s
Date:        %s

package %s;

sub data { {} }

1;
END_MODLIST

    # If we put "package CPAN::Modulelist" in the above string, it
    # fools the PAUSE indexer into thinking that we provide the
    # CPAN::Modulelist package.  But we don't.  To get around this,
    # I'm going to inject the string "CPAN::Modulelist" into the
    # template.

    return sprintf $template, $0, scalar localtime, 'CPAN::Modulelist';
}

#------------------------------------------------------------------------------

sub _create_db {
    my ($self) = @_;

    my $db = Pinto::Database->new( config => $self->config );
    $db->deploy;

    return;
}

#------------------------------------------------------------------------------

sub _create_stack {
    my ($self, %args) = @_;

    my $stk_name  = Pinto::Util::validate_stack_name($args{name} || 'init');
    my $stk_description = $args{description} || 'the initial stack';

    my $repo  = Pinto::Repository->new(config => $self->config);
    my $stack = $repo->create_stack(name => $stk_name, is_default => 1);

    $stack->set_property(description => $stk_description);
    $stack->close(message => 'Created initial stack', committed_by => current_user);

    $repo->create_stack_filesystem(stack => $stack);
    $repo->write_index(stack => $stack);

    return;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Initializer - Initializes a new Pinto repository

=head1 VERSION

version 0.063

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
