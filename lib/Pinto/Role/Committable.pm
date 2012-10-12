# ABSTRACT: Role for actions that commit changes to the repository

package Pinto::Role::Committable;

use Moose::Role;
use MooseX::Types::Moose qw(Bool Str);

use Try::Tiny;
use IO::Interactive qw(is_interactive);

use Pinto::CommitMessage;
use Pinto::Exception qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.058'; # VERSION

#------------------------------------------------------------------------------

has dryrun => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has message => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_message',
);

#------------------------------------------------------------------------------

requires qw( execute message_primer );

#------------------------------------------------------------------------------

around execute => sub {
    my ($orig, $self, @args) = @_;

    $self->repos->db->txn_begin;

    my $result = try   { $self->$orig(@args) }
                 catch { $self->repos->db->txn_rollback; die $_ };

    if ($self->dryrun) {
        $self->notice('Dryrun -- rolling back database');
        $self->repos->db->txn_rollback;
        $self->repos->clean_files;
    }
    elsif (not $result->made_changes) {
        $self->notice('No changes were actually made');
        $self->repos->db->txn_rollback;
    }
    else {
        $self->debug('Committing changes to database');
        $self->repos->db->txn_commit;
    }

    return $self->result;
};

#------------------------------------------------------------------------------

sub edit_message {
    my ($self, %args) = @_;

    my $stacks = $args{stacks} || [];
    my $primer = $args{primer} || $self->message_primer || '';

    return $self->message if $self->has_message;
    return $primer if not is_interactive;

    my $message = Pinto::CommitMessage->new(stacks => $stacks, primer => $primer)->edit;
    throw 'Aborting due to empty commit message' if $message !~ /\S+/;

    return $message;
}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Committable - Role for actions that commit changes to the repository

=head1 VERSION

version 0.058

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
