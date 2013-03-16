# ABSTRACT: Construct Action objects

package Pinto::ActionFactory;

use Moose;
use MooseX::Types::Moose qw(Str);
use MooseX::MarkAsMethods (autoclean => 1);

use Class::Load;

use Pinto::Exception qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.065_02'; # VERSION

#------------------------------------------------------------------------------

has repo  => (
    is       => 'ro',
    isa      => 'Pinto::Repository',
    required => 1,
);


has action_class_namespace => (
    is        => 'ro',
    isa       => Str,
    default   => 'Pinto::Action',
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------

sub create_action {
    my ($self, $action_name, %action_args) = @_;

    @action_args{qw(config logger repo)} = ($self->config, $self->logger, $self->repo);
    my $action_class = $self->load_class_for_action(name => $action_name);
    my $action = $action_class->new(%action_args);

    return $action;
}

#------------------------------------------------------------------------------

sub load_class_for_action {
    my ($self, %args) = @_;

    my $action_name = ucfirst $args{name} || throw 'Must specify an action name';
    my $action_class = $self->action_class_namespace . '::' . $action_name;
    Class::Load::load_class($action_class);

    return $action_class;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::ActionFactory - Construct Action objects

=head1 VERSION

version 0.065_02

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
