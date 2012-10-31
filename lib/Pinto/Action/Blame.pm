# ABSTRACT: Show who added packages to the stack

package Pinto::Action::Blame;

use Moose;
use MooseX::Types::Moose qw(Bool Int Undef);

use Pinto::Types qw(StackName StackDefault);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.061'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has stack => (
    is        => 'ro',
    isa       => StackName | StackDefault,
    default   => undef,
);


has revision => (
    is        => 'ro',
    isa       => Int | Undef,
    default   => undef,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repo->get_stack(name => $self->stack);
    my $rcrs  = $self->repo->db->schema->resultset('RegistrationChange');

    # STRATEGY: For each registration in the current head of the stack, find
    # the most recent registration change which inserted the package referenced
    # in the registration.  I think you can probably optimize this by using
    # a correlated subquery.

    my $attrs = {prefetch => {package => 'distribution'},
                 order_by => [ qw(package.name) ] };

    for my $reg ($stack->registrations({}, $attrs)) {
        my $pkg   = $reg->package;
        my $attrs = {prefetch => 'revision'};
        my $where = {'revision.stack' => $stack->id, package => $pkg->id, event => 'insert'};
        my $last_insert = $rcrs->search($where, $attrs)->get_column('id')->max;

        my $change = $rcrs->find({id => $last_insert}, $attrs);
        my $revno  = $change->revision->number;
        my $user   = $change->revision->committed_by;
        my $regstr = $reg->to_string('%y %-40n %12v %p');

        $self->say( sprintf('%4d %8s %s', $revno, $user, $regstr) );
    }

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Blame - Show who added packages to the stack

=head1 VERSION

version 0.061

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
