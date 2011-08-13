package Pinto::Server::Dispatch;

# ABSTRACT: Dispatch table for a Pinto server

use strict;
use warnings;

use base 'CGI::Application::Dispatch';

#-----------------------------------------------------------------------------

our $VERSION = '0.009'; # VERSION

#-----------------------------------------------------------------------------

sub dispatch_args {
    return {
        table => [ 'add[post]' => {app => 'Pinto::Server', rm => 'add'} ],
    };
}

#----------------------------------------------------------------------------
1;

__END__
=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Server::Dispatch - Dispatch table for a Pinto server

=head1 VERSION

version 0.009

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

