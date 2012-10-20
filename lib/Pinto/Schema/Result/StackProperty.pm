use utf8;
package Pinto::Schema::Result::StackProperty;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';


__PACKAGE__->table("stack_property");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "stack",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "key",
  { data_type => "text", is_nullable => 0 },
  "key_canonical",
  { data_type => "text", is_nullable => 0 },
  "value",
  { data_type => "text", default_value => "", is_nullable => 1 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint("stack_key_canonical_unique", ["stack", "key_canonical"]);


__PACKAGE__->add_unique_constraint("stack_key_unique", ["stack", "key"]);


__PACKAGE__->belongs_to(
  "stack",
  "Pinto::Schema::Result::Stack",
  { id => "stack" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);



with 'Pinto::Role::Schema::Result';


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-10-19 19:06:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m1Uj0OjnjQqw56mv+hPr6g

#------------------------------------------------------------------------------

# ABSTRACT: Represents stack metadata

#------------------------------------------------------------------------------

our $VERSION = '0.059'; # VERSION

#------------------------------------------------------------------------------

sub FOREIGNBUILDARGS {
  my ($class, $args) = @_;

  $args ||= {};
  $args->{key_canonical} = lc $args->{key};

  return $args;
}

#------------------------------------------------------------------------------


__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::Result::StackProperty - Represents stack metadata

=head1 VERSION

version 0.059

=head1 NAME

Pinto::Schema::Result::StackProperty

=head1 TABLE: C<stack_property>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 stack

  data_type: 'integer'
  is_foreign_key: 1
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

=head2 C<stack_key_canonical_unique>

=over 4

=item * L</stack>

=item * L</key_canonical>

=back

=head2 C<stack_key_unique>

=over 4

=item * L</stack>

=item * L</key>

=back

=head1 RELATIONS

=head2 stack

Type: belongs_to

Related object: L<Pinto::Schema::Result::Stack>

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
