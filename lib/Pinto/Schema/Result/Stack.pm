use utf8;
package Pinto::Schema::Result::Stack;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';


__PACKAGE__->table("stack");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "is_default",
  { data_type => "integer", is_nullable => 0 },
  "last_modified_on",
  { data_type => "integer", is_nullable => 0 },
  "last_modified_by",
  { data_type => "text", is_nullable => 0 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint("name_unique", ["name"]);


__PACKAGE__->has_many(
  "registrations",
  "Pinto::Schema::Result::Registration",
  { "foreign.stack" => "self.id" },
  { cascade_copy => 0, cascade_delete => 1 },
);


__PACKAGE__->has_many(
  "stack_properties",
  "Pinto::Schema::Result::StackProperty",
  { "foreign.stack" => "self.id" },
  { cascade_copy => 0, cascade_delete => 1 },
);



with 'Pinto::Role::Schema::Result';


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-05-03 00:46:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2X9BNMm9xjPjECGdDWDVXA

#-------------------------------------------------------------------------------

# ABSTRACT: Represents a named set of Packages

#-------------------------------------------------------------------------------

our $VERSION = '0.047'; # VERSION

#-------------------------------------------------------------------------------

use String::Format;

use Pinto::Util;
use Pinto::Exception qw(throw);

use overload ( '""'     => 'to_string' );

#-------------------------------------------------------------------------------
# Schema::Loader does not create many-to-many relationships for us.  So we
# must create them by hand here...

__PACKAGE__->many_to_many( packages => 'regsitry', 'package' );

#------------------------------------------------------------------------------

sub FOREIGNBUILDARGS {
  my ($class, $args) = @_;

  $args ||= {};
  $args->{is_default} ||= 0;
  $args->{last_modified_on} ||= time;
  $args->{last_modified_by} ||= $ENV{USER};

  return $args;
}


#------------------------------------------------------------------------------

before delete => sub {
    my ($self, @args) = @_;
    throw 'You cannot remove the default stack' if $self->is_default;
};

#------------------------------------------------------------------------------

before is_default => sub {
    my ($self, @args) = @_;
    throw 'You cannot directly set is_default.  Use mark_as_default' if @args;
};

#------------------------------------------------------------------------------

sub registration {
    my ($self, %args) = @_;

    my $pkg_name = ref $args{package} ? $args{package}->name : $args{package};
    my $attrs = {key => 'stack_package_name_unique', prefetch => 'package'};

    return $self->find_related('registrations', {package_name => $pkg_name}, $attrs);
}

#------------------------------------------------------------------------------

sub copy {
  my ($self, $changes) = @_;

  $changes ||= {};
  my $to_stack_name = Pinto::Util::normalize_stack_name( $changes->{name} );

  throw "Stack $to_stack_name already exists"
    if $self->result_source->resultset->find({name => $to_stack_name});

  $changes->{is_default} = 0; # Never duplicate the default flag

  return $self->next::method($changes);
}

#------------------------------------------------------------------------------

sub copy_deeply {
    my ($self, @args) = @_;

    my $copy = $self->copy(@args);
    $self->copy_properties(to => $copy);
    $self->copy_members(to => $copy);
    $copy->touch($self->last_modified_on);

    return $copy;
}

#------------------------------------------------------------------------------

sub copy_properties {
    my ($self, %args) = @_;

    my $to_stack = $args{to};
    my $props = $self->get_properties;
    $to_stack->set_properties($props);

    return $self;
}

#------------------------------------------------------------------------------

sub copy_members {
    my ($self, %args) = @_;

    my $to_stack = $args{to};
    $self->info("Copying stack $self into stack $to_stack");

    for my $registration ( $self->registrations ) {
        my $pkg = $registration->package;
        $self->debug( sub{"Copying package $pkg into stack $to_stack"} );
        $registration->copy( { stack => $to_stack } );
    }

    return $self;
}

#------------------------------------------------------------------------------

sub mark_as_default {
    my ($self) = @_;

    if ($self->is_default) {
        $self->warning("Stack $self is already the default");
        return 0;
    }

    $self->debug('Marking all stacks as non-default');
    my $rs = $self->result_source->resultset->search;
    $rs->update_all( {is_default => 0} );

    $self->warning("Marking stack $self as default");
    $self->update({is_default => 1});

    return 1;
}

#------------------------------------------------------------------------------

sub touch {
    my ($self, $time, $user) = @_;

    return unless $self->in_storage;

    my %changes;
    $changes{last_modified_on} = $time || time;
    $changes{last_modified_by} = $user || $ENV{USER};

    $self->update( \%changes );

    return $self;
}

#-------------------------------------------------------------------------------

sub get_property {
    my ($self, @prop_names) = @_;

    my %props = %{ $self->get_properties };
    return @props{@prop_names};
}

#-------------------------------------------------------------------------------

sub get_properties {
    my ($self) = @_;

    my @props = $self->search_related('stack_properties')->all;

    return { map { $_->name => $_->value } @props };
}

#-------------------------------------------------------------------------------

sub set_property {
    my ($self, $prop_name, $value) = @_;
    return $self->set_properties( {$prop_name => $value} );
}

#-------------------------------------------------------------------------------

sub set_properties {
    my ($self, $props) = @_;

    my $attrs  = {key => 'stack_name_unique'};
    while (my ($name, $value) = each %{$props}) {
        $name = Pinto::Util::normalize_property_name($name);
        my $nv_pair = {name => $name, value => $value};
        $self->update_or_create_related('stack_properties', $nv_pair, $attrs);
    }

    $self->touch;
    return $self;
}

#-------------------------------------------------------------------------------

sub delete_property {
    my ($self, @prop_names) = @_;

    my $attrs = {key => 'stack_name_unique'};

    for my $prop_name (@prop_names) {
          my $where = {name => $prop_name};
          my $prop = $self->find_related('stack_properties', $where, $attrs);
          $prop->delete if $prop;
    }

    return $self;
}

#-------------------------------------------------------------------------------

sub delete_properties {
    my ($self) = @_;

    my $props_rs = $self->search_related_rs('stack_properties');
    $props_rs->delete;

    return $self;
}

#-------------------------------------------------------------------------------

sub merge {
    my ($self, %args) = @_;

    my $to_stk = $args{to};

    my $conflicts;
    for my $reg ($self->registrations) {
        $self->info("Merging package $reg into stack $to_stk");
        $conflicts += $reg->merge(%args);
    }

    throw "There were $conflicts conflicts.  Merge aborted" if $conflicts;

    return 1;
}

#------------------------------------------------------------------------------

sub to_string {
    my ($self, $format) = @_;

    my %fspec = (
           k => sub { $self->name                                          },
           M => sub { $self->is_default              ? '*' : ' '           },
           j => sub { $self->last_modified_by                              },
           u => sub { $self->last_modified_on                              },
           U => sub { Pinto::Util::ls_time_format($self->last_modified_on) },
           e => sub { $self->get_property('description')                   },
    );

    $format ||= $self->default_format();
    return String::Format::stringf($format, %fspec);
}

#-------------------------------------------------------------------------------

sub default_format {
    my ($self) = @_;

    return '%k';
}

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Schema::Result::Stack - Represents a named set of Packages

=head1 VERSION

version 0.047

=head1 NAME

Pinto::Schema::Result::Stack

=head1 TABLE: C<stack>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 is_default

  data_type: 'integer'
  is_nullable: 0

=head2 last_modified_on

  data_type: 'integer'
  is_nullable: 0

=head2 last_modified_by

  data_type: 'text'
  is_nullable: 0

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=head1 RELATIONS

=head2 registrations

Type: has_many

Related object: L<Pinto::Schema::Result::Registration>

=head2 stack_properties

Type: has_many

Related object: L<Pinto::Schema::Result::StackProperty>

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
