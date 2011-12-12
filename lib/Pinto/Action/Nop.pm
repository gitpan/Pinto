package Pinto::Action::Nop;

# ABSTRACT: A no-op action

use Moose;

use MooseX::Types::Moose qw(Int);

extends 'Pinto::Action';

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.028'; # VERSION

#------------------------------------------------------------------------------

has sleep => (
    is      => 'ro',
    isa     => Int,
    default => 0,
);

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    if ( my $sleep = $self->sleep() ) {
        $self->debug("Process $$ sleeping for $sleep seconds");
        sleep $self->sleep();
    }

    return 0;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------


1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Nop - A no-op action

=head1 VERSION

version 0.028

=head1 DESCRIPTION

This action does nothing.  It can be used to get Pinto to initialize
the store and load the indexes without performing any real operations
on them.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
