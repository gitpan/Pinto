use utf8;
package Pinto::Schema::Result::Prerequisite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';


__PACKAGE__->table("prerequisite");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "distribution",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "package_name",
  { data_type => "text", is_nullable => 0 },
  "package_version",
  { data_type => "text", is_nullable => 0 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint(
  "distribution_package_name_unique",
  ["distribution", "package_name"],
);


__PACKAGE__->belongs_to(
  "distribution",
  "Pinto::Schema::Result::Distribution",
  { id => "distribution" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);



with 'Pinto::Role::Schema::Result';


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-04-30 14:24:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0deC0FNUyI51MUzBgm7Q9Q

#------------------------------------------------------------------------------

# ABSTRACT: Represents a Distribution -> Package dependency

#------------------------------------------------------------------------------

use Pinto::PackageSpec;

#------------------------------------------------------------------------------

our $VERSION = '0.041'; # VERSION

#------------------------------------------------------------------------------
# NOTE: We often convert a Prerequsite to/from a PackageSpec object. They don't
# use quite the same names for their attributes, so we shuffle them around here.

sub FOREIGNBUILDARGS {
    my ($class, $args) = @_;

    $args ||= {};
    $args->{package_name}      = delete $args->{name};
    $args->{package_version}   = delete $args->{version};

    return $args;
}

#------------------------------------------------------------------------------

sub as_spec {
    my ($self) = @_;

    return Pinto::PackageSpec->new( name    => $self->package_name,
                                    version => $self->package_version );
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::Result::Prerequisite - Represents a Distribution -> Package dependency

=head1 VERSION

version 0.041

=head1 NAME

Pinto::Schema::Result::Prerequisite

=head1 TABLE: C<prerequisite>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 distribution

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 package_name

  data_type: 'text'
  is_nullable: 0

=head2 package_version

  data_type: 'text'
  is_nullable: 0

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=head1 UNIQUE CONSTRAINTS

=head2 C<distribution_package_name_unique>

=over 4

=item * L</distribution>

=item * L</package_name>

=back

=head1 RELATIONS

=head2 distribution

Type: belongs_to

Related object: L<Pinto::Schema::Result::Distribution>

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
