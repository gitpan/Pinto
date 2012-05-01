package App::Pinto::Admin::DispatchingCommand;

# ABSTRACT: Base class for pinto-admin commands that redispatch to subcommands

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base qw(App::Cmd::Subdispatch App::Pinto::Admin::Command);

#-----------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub plugin_search_path {
    my ($self) = @_;

    my $prefix    = $self->subcommand_namespace_prefix();
    my ($command) = $self->command_names();

    return "${prefix}::${command}";
}

#-----------------------------------------------------------------------------

sub subcommand_namespace_prefix {
    return 'App::Pinto::Admin::Subcommand';
}

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::DispatchingCommand - Base class for pinto-admin commands that redispatch to subcommands

=head1 VERSION

version 0.040_001

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
