package Pinto::Role::Log;

# ABSTRACT: Simple logger for Pinto

use Moose::Role;
use Log::Log4perl;

#------------------------------------------------------------------------------

our $VERSION = '0.001'; # VERSION

#------------------------------------------------------------------------------

BEGIN { Log::Log4perl->easy_init() }

#------------------------------------------------------------------------------

has 'log' => (
	is      => 'rw',
	isa     => 'Log::Log4perl::Logger',
	lazy    => 1,
	default => sub { return Log::Log4perl->get_logger(ref($_[0])) }
);

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Log - Simple logger for Pinto

=head1 VERSION

version 0.001

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
