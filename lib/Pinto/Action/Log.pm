# ABSTRACT: Show revision log for a stack

package Pinto::Action::Log;

use Moose;
use MooseX::Types::Moose qw(Str);
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::RevisionWalker;
use Pinto::Types qw(StackName StackDefault);


#------------------------------------------------------------------------------

our $VERSION = '0.065_01'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Colorable );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | StackDefault,
    default   => undef,
);


has format => (
    is      => 'ro',
    isa     => Str,
    builder => '_build_format',
    lazy    => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack  = $self->repo->get_stack($self->stack);
    my $walker = Pinto::RevisionWalker->new(start => $stack->head);

    while (my $revision = $walker->next) {
        $self->say( $revision->to_string($self->format) ); 
    }

    return $self->result;
}

#------------------------------------------------------------------------------

sub _build_format {
    my ($self) = @_;

    my $c = $self->color_2;
    my $r = $self->color_0;

    return <<"END_FORMAT";
${c}revision %I${r}
Date: %u
User: %j 

%{4}G
END_FORMAT

}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Log - Show revision log for a stack

=head1 VERSION

version 0.065_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
