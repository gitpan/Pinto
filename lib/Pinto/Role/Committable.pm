# ABSTRACT: Role for actions that commit changes to the repository

package Pinto::Role::Committable;

use Moose::Role;
use MooseX::Types::Moose qw(Bool Str);

use Try::Tiny;

use Pinto::CommitMessage;
use Pinto::Exception qw(throw);
use Pinto::Util qw(is_interactive interpolate);

#------------------------------------------------------------------------------

our $VERSION = '0.065'; # VERSION

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

has use_default_message => (
    is         => 'ro',
    isa        => Bool,
    default    => 0,
);

#------------------------------------------------------------------------------

requires qw( execute message_title );

#------------------------------------------------------------------------------

around execute => sub {
    my ($orig, $self, @args) = @_;

    $self->repo->db->txn_begin;

    my $result = try   { $self->$orig(@args) }
                 catch { $self->repo->db->txn_rollback; die $_ };

    if ($self->dryrun) {
        $self->notice('Dryrun -- rolling back database');
        $self->repo->db->txn_rollback;
        $self->repo->clean_files;
    }
    elsif (not $result->made_changes) {
        $self->notice('No changes were actually made');
        $self->repo->db->txn_rollback;
    }
    else {
        $self->debug('Committing changes to database');
        $self->repo->db->txn_commit;
    }

    return $self->result;
};

#------------------------------------------------------------------------------

sub edit_message {
    my ($self, %args) = @_;

    my $stacks =  $args{stacks} || [];
    my $title  =  $args{title}  || $self->message_title || '';

    return interpolate($self->message)
        if $self->has_message and $self->message =~ /\S+/;

    return $title
        if $self->has_message and $self->message !~ /\S+/;

    return $title
        if $self->use_default_message;

    return $title
        if not is_interactive;

    my $message = Pinto::CommitMessage->new(stacks => $stacks, title => $title)->edit;
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

version 0.065

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
