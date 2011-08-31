package App::Pinto::Admin::Command::add;

# ABSTRACT: add your own distributions to the repository

use strict;
use warnings;

use Pinto::Util;

#------------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.022'; # VERSION

#-----------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return ( $self->SUPER::opt_spec(),

        [ 'author=s'    => 'Your (alphanumeric) author ID' ],
        [ 'message|m=s' => 'Prepend a message to the VCS log' ],
        [ 'nocommit'    => 'Do not commit changes to VCS' ],
        [ 'noinit'      => 'Do not pull/update from VCS' ],
        [ 'tag=s'       => 'Specify a VCS tag name' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --repos=PATH $command [OPTIONS] FILE1 [FILE2 ...]
%c --repos=PATH $command [OPTIONS] URL1 [URL2 ...]
%c --repos=PATH $command [OPTIONS] < LIST_OF_FILES_OR_URLS
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my @args = @{$args} ? @{$args} : Pinto::Util::args_from_fh(\*STDIN);
    return 0 if not @args;

    $self->pinto->new_action_batch( %{$opts} );
    $self->pinto->add_action('Add', %{$opts}, dist => $_) for @args;
    my $result = $self->pinto->run_actions();

    return $result->is_success() ? 0 : 1;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::add - add your own distributions to the repository

=head1 VERSION

version 0.022

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
