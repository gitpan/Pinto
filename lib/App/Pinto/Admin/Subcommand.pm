package App::Pinto::Admin::Subcommand;

# ABSTRACT: Base class for pinto-admin subcommands

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#-----------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

sub command_namespace_prefix {
    return __PACKAGE__;
}

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Subcommand - Base class for pinto-admin subcommands

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
