package Pinto::Store::VCS;

# ABSTRACT: Base class for VCS-backed Stores

use Moose;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.038'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends qw( Pinto::Store );

#------------------------------------------------------------------------------
# Moose attributes

has _paths => (
    is        => 'ro',
    isa       => 'HashRef[Path::Class]',
    init_arg  => undef,
    clearer   => '_clear_paths',
    default   => sub { {} },
);

#------------------------------------------------------------------------------
# Methods

augment initialize => sub {
    my ($self) = @_;

    $self->info('Updating working copy');

    inner();

    return $self;
};

#------------------------------------------------------------------------------

augment add_path => sub {
    my ($self, %args) = @_;

    $self->debug("Scheduling $args{path} for addition to VCS");

    inner();

    return $self;
};

#------------------------------------------------------------------------------

augment remove_path => sub {
    my ($self, %args) = @_;

    $self->debug("Scheduling $args{path} for removal from VCS");

    inner();

    return $self;
};

#------------------------------------------------------------------------------

augment commit => sub {
    my ($self) = @_;

    $self->notice('Committing changes to VCS');

    inner();

    $self->_clear_paths();

    return $self;
};

#------------------------------------------------------------------------------

sub mark_path_for_commit {
    my ($self, $path) = @_;

    $self->_paths->{ $path } = $path;

    return $self;
}

#------------------------------------------------------------------------------

sub paths_to_commit {
    my ($self) = @_;

    # TODO: consider reducing this to the shortest list of stems, then
    # just allow the VCS to descend into those paths recursively.

    return [ sort values %{ $self->_paths() } ];
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store::VCS - Base class for VCS-backed Stores

=head1 VERSION

version 0.038

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

