package Pinto::Result;

# ABSTRACT: The result from running a Batch of Actions

use Moose;

use MooseX::Types::Moose qw(Bool ArrayRef);

use overload ('""' => 'to_string');

#-----------------------------------------------------------------------------

our $VERSION = '0.028'; # VERSION

#------------------------------------------------------------------------------
# Moose attributes

has changes_made    => (
    is        => 'ro',
    isa       => Bool,
    init_arg  => undef,
    writer    => '_set_changes_made',
    default   => 0,
);

has exceptions => (
    is         => 'ro',
    isa        => ArrayRef,
    traits     => [ 'Array' ],
    default    => sub { [] },
    handles    => {add_exception => 'push'},
    init_arg   => undef,
    auto_deref => 1,
);

#-----------------------------------------------------------------------------

sub is_success {
    my ($self) = @_;

    return @{ $self->exceptions() } == 0;
}

#-----------------------------------------------------------------------------
# HACK! Confusing: "made_changes" vs. "changes_made"

sub made_changes {
    my ($self) = @_;

    $self->_set_changes_made(1);

    return $self;
}

#-----------------------------------------------------------------------------

sub to_string {
    my ($self) = @_;

    my $string = join "\n", map { "$_" } $self->exceptions();
    $string .= "\n" unless $string =~ m/\n $/x;

    return $string;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Result - The result from running a Batch of Actions

=head1 VERSION

version 0.028

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
