package Pinto::Exceptions;

# ABSTRACT: Exception classes for Pinto

use strict;
use warnings;

#-----------------------------------------------------------------------------

our $VERSION = '0.026'; # VERSION

#-----------------------------------------------------------------------------

use Exception::Class (

     'Pinto::Exception' => {
        alias => 'throw_error',
     },

     'Pinto::Exception::Action'  => {
        isa   => 'Pinto::Exception',
        alias => 'throw_action',
     },

     'Pinto::Exception::Fatal'  => {
        isa   => 'Pinto::Exception',
        alias => 'throw_fatal',
     },

     'Pinto::Exception::IllegalArguments'  => {
         isa   => 'Pinto::Exception::Fatal',
         alias => 'throw_args',
     },

     'Pinto::Exception::InputOutput'  => {
         isa   => 'Pinto::Exception::Fatal',
         alias => 'throw_io',
     },

     'Pinto::Exception::Database'  => {
         isa   => 'Pinto::Exception::Fatal',
         alias => 'throw_db',
     },

     'Pinto::Exception::DuplicateDistribution'  => {
         isa   => 'Pinto::Exception',
         alias => 'throw_dupe',
     },

     'Pinto::Exception::DistributionNotFound'  => {
         isa   => 'Pinto::Exception',
         alias => 'throw_nodist',
     },

     'Pinto::Exception::DistributionParse'  => {
         isa   => 'Pinto::Exception',
         alias => 'throw_dist_parse',
     },

     'Pinto::Exception::EmptyDistribution'  => {
         isa   => 'Pinto::Exception',
         alias => 'throw_empty_dist',
     },

     'Pinto::Exception::UnauthorizedPackage'  => {
         isa   => 'Pinto::Exception',
         alias => 'throw_unauthorized',
     },

     'Pinto::Exception::IllegalVersion'  => {
         isa   => 'Pinto::Exception',
         alias => 'throw_version',
     },

     'Pinto::Exception::VCS'  => {
         isa   => 'Pinto::Exception::Fatal',
         alias => 'throw_vcs',
     },
);

#-----------------------------------------------------------------------------

use base 'Exporter';

our @EXPORT_OK = qw(throw_error throw_action throw_fatal throw_version);

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Exceptions - Exception classes for Pinto

=head1 VERSION

version 0.026

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
