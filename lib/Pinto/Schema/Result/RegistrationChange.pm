use utf8;
package Pinto::Schema::Result::RegistrationChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';


__PACKAGE__->table("registration_change");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "event",
  { data_type => "text", is_nullable => 0 },
  "package",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "distribution",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "is_pinned",
  { data_type => "boolean", is_nullable => 0 },
  "revision",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint(
  "event_package_revision_unique",
  ["event", "package", "revision"],
);


__PACKAGE__->belongs_to(
  "distribution",
  "Pinto::Schema::Result::Distribution",
  { id => "distribution" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


__PACKAGE__->belongs_to(
  "package",
  "Pinto::Schema::Result::Package",
  { id => "package" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


__PACKAGE__->belongs_to(
  "revision",
  "Pinto::Schema::Result::Revision",
  { id => "revision" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);



with 'Pinto::Role::Schema::Result';


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-12 10:48:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ju7Rbyewmn2EUaELpNV/MA

#-------------------------------------------------------------------------------

# ABSTRACT: A single change to the registry

#-------------------------------------------------------------------------------

our $VERSION = '0.063'; # VERSION

#-------------------------------------------------------------------------------

use String::Format;

use Pinto::Exception qw(throw);

use overload ( q{""} => 'to_string' );

#-------------------------------------------------------------------------------

sub undo {
    my ($self, %args) = @_;

    my $stack = $args{stack};

    my $state = { stack        => $stack->id,
                  package      => $self->package->id,
                  distribution => $self->distribution->id,
                  is_pinned    => $self->is_pinned };

    my $event = $self->event;
    if ($event eq 'insert') {

        my $attrs = {key => 'stack_package_unique'};
        my $reg = $self->result_source->schema->resultset('Registration')->find($state, $attrs);
        throw "Found no registrations matching $self on stack $stack" if not $reg;

        $reg->delete;
        $self->debug("Removed $reg");

    }
    elsif ($event eq 'delete') {

        my $reg = $self->result_source->schema->resultset('Registration')->create($state);

        $self->debug("Restored $reg");

    }
    else {
      throw "Don't know how to undo event $event";
    }

    return $self;

}

#-------------------------------------------------------------------------------

sub to_string {
   my ($self, $format) = @_;


    my %fspec = (
         A => sub { $self->event eq 'insert'                    ? 'A' : 'D'         },
         n => sub { $self->package->name                                            },
         N => sub { $self->package->vname                                           },
         v => sub { $self->package->version                                         },
         m => sub { $self->package->distribution->is_devel      ? 'd' : 'r'         },
         p => sub { $self->package->distribution->path                              },
         P => sub { $self->package->distribution->native_path                       },
         f => sub { $self->package->distribution->archive                           },
         s => sub { $self->package->distribution->is_local      ? 'l' : 'f'         },
         S => sub { $self->package->distribution->source                            },
         a => sub { $self->package->distribution->author                            },
         d => sub { $self->package->distribution->name                              },
         D => sub { $self->package->distribution->vname                             },
         w => sub { $self->package->distribution->version                           },
         u => sub { $self->package->distribution->url                               },
         k => sub { $self->revision->stack->name                                    },
         M => sub { $self->revision->stack->is_default          ? '*' : ' '         },
         e => sub { $self->revision->stack->get_property('description')             },
         j => sub { $self->revision->stack->head_revision->committed_by             },
         u => sub { $self->revision->revision->committed_on                         },
         y => sub { $self->is_pinned                            ? '+' : ' '         },
    );

    # Some attributes are just undefined, usually because of
    # oddly named distributions and other old stuff on CPAN.
    no warnings 'uninitialized';  ## no critic qw(NoWarnings);

    $format ||= $self->default_format();
    return String::Format::stringf($format, %fspec);
}

sub default_format {

    return '%A%y %a/%f/%N';
}

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::Result::RegistrationChange - A single change to the registry

=head1 VERSION

version 0.063

=head1 NAME

Pinto::Schema::Result::RegistrationChange

=head1 TABLE: C<registration_change>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 event

  data_type: 'text'
  is_nullable: 0

=head2 package

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 distribution

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 is_pinned

  data_type: 'boolean'
  is_nullable: 0

=head2 revision

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=head1 UNIQUE CONSTRAINTS

=head2 C<event_package_revision_unique>

=over 4

=item * L</event>

=item * L</package>

=item * L</revision>

=back

=head1 RELATIONS

=head2 distribution

Type: belongs_to

Related object: L<Pinto::Schema::Result::Distribution>

=head2 package

Type: belongs_to

Related object: L<Pinto::Schema::Result::Package>

=head2 revision

Type: belongs_to

Related object: L<Pinto::Schema::Result::Revision>

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

