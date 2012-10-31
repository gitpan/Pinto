use utf8;
package Pinto::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-04-29 01:03:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yRlbDgtAuKaDHF9i1Kwqsg
#-------------------------------------------------------------------------------

# ABSTRACT: The DBIx::Class::Schema for Pinto

#-------------------------------------------------------------------------------

our $VERSION = '0.061'; # VERSION

#-------------------------------------------------------------------------------

use Readonly;

#-------------------------------------------------------------------------------

Readonly::Scalar our $SCHEMA_VERSION => 4;

#-------------------------------------------------------------------------------

has logger => (
    is      => 'rw',
    isa     => 'Pinto::Logger',
    handles => [ qw(debug notice info warning error fatal) ],
);

#-------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema - The DBIx::Class::Schema for Pinto

=head1 VERSION

version 0.061

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
