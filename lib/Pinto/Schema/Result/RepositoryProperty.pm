use utf8;
package Pinto::Schema::Result::RepositoryProperty;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';


__PACKAGE__->table("repository_property");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "key",
  { data_type => "text", is_nullable => 0 },
  "key_canonical",
  { data_type => "text", is_nullable => 0 },
  "value",
  { data_type => "text", default_value => "", is_nullable => 1 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint("key_canonical_unique", ["key_canonical"]);


__PACKAGE__->add_unique_constraint("key_unique", ["key"]);



with 'Pinto::Role::Schema::Result';


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-12 10:48:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pT7O2c2JHonL/JGkkYv1Rw

#-------------------------------------------------------------------------------

# ABSTRACT: Repository metadata

#-------------------------------------------------------------------------------

our $VERSION = '0.065'; # VERSION

#-------------------------------------------------------------------------------

sub FOREIGNBUILDARGS {
  my ($class, $args) = @_;

  $args ||= {};
  $args->{key_canonical} = lc $args->{key};

  return $args;
}

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::Result::RepositoryProperty - Repository metadata

=head1 VERSION

version 0.065

=head1 NAME

Pinto::Schema::Result::RepositoryProperty

=head1 TABLE: C<repository_property>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 key

  data_type: 'text'
  is_nullable: 0

=head2 key_canonical

  data_type: 'text'
  is_nullable: 0

=head2 value

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 1

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=head1 UNIQUE CONSTRAINTS

=head2 C<key_canonical_unique>

=over 4

=item * L</key_canonical>

=back

=head2 C<key_unique>

=over 4

=item * L</key>

=back

=head1 L<Moose> ROLES APPLIED

=over 4

=item * L<Pinto::Role::Schema::Result>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
