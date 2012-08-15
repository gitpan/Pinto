package Pinto::Result;

# ABSTRACT: The result from running an Action

use Moose;

use MooseX::Types::Moose qw(Bool);

#-----------------------------------------------------------------------------

our $VERSION = '0.050'; # VERSION

#------------------------------------------------------------------------------

has made_changes => (
    is        => 'ro',
    isa       => Bool,
    writer    => '_set_made_changes',
    default   => 0,
);



has was_successful => (
    is         => 'ro',
    isa        => Bool,
    writer     => '_set_was_successful',
    default    => 1,
);

#-----------------------------------------------------------------------------

sub failed {
    my ($self) = @_;
    $self->_set_was_successful(0);
    return $self;
}

#-----------------------------------------------------------------------------

sub changed {
    my ($self) = @_;
    $self->_set_made_changes(1);
    return $self;
}

#-----------------------------------------------------------------------------

sub exit_status {
    my ($self) = @_;
    return $self->was_successful ? 0 : 1;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Result - The result from running an Action

=head1 VERSION

version 0.050

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
