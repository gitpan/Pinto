# ABSTRACT: Add a local distribution into the repository

package Pinto::Action::Add;

use Moose;
use MooseX::Types::Moose qw(Bool Str);
use MooseX::MarkAsMethods (autoclean => 1);
use Try::Tiny;

use Pinto::Util qw(sha256 current_author_id);
use Pinto::Types qw(AuthorID FileList StackName StackObject StackDefault);
use Pinto::Exception qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.065_01'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::PauseConfig Pinto::Role::Committable );

#------------------------------------------------------------------------------

has author => (
    is         => 'ro',
    isa        => AuthorID,
    default    => sub { uc($_[0]->pausecfg->{user} || '') || current_author_id },
    lazy       => 1,
);


has archives  => (
    isa       => FileList,
    traits    => [ qw(Array) ],
    handles   => {archives => 'elements'},
    required  => 1,
    coerce    => 1,
);


has stack => (
    is       => 'ro',
    isa      => StackName | StackDefault | StackObject,
    default  => undef,
);


has pin => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);


has no_recurse => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);


has no_fail => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);


has message_title => (
    is        => 'rw',
    isa       => Str,
    init_arg  => undef,
    default   => '',
);

#------------------------------------------------------------------------------

sub BUILD {
    my ($self, $args) = @_;

    my @missing = grep { not -e $_ } $self->archives;
    $self->error("Archive $_ does not exist") for @missing;

    my @unreadable = grep { -e $_ and not -r $_ } $self->archives;
    $self->error("Archive $_ is not readable") for @unreadable;

    throw "Some archives are missing or unreadable"
        if @missing or @unreadable;

    return $self;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repo->get_stack($self->stack)->start_revision;

    my (@successful, @failed);
    for my $archive ($self->archives) {

        try   {
            $self->repo->svp_begin; 
            my $dist = $self->_add($archive, $stack);
            push @successful, $dist;
        }
        catch {
            die $_ unless $self->no_fail; 

            $self->repo->svp_rollback;

            $self->error("$_");
            $self->error("$archive failed...continuing anyway");
            push @failed, $archive;
        }
        finally {
            my ($error) = @_;
            $self->repo->svp_release unless $error;
        };
    }

    return $self->result if $self->dry_run or $stack->has_not_changed;

    my $msg_title = $self->generate_message_title(@successful);
    my $msg = $self->compose_message(stack => $stack, title => $msg_title);

    $stack->commit_revision(message => $msg);

    return $self->result->changed;
}

#------------------------------------------------------------------------------

sub _add {
    my ($self, $archive, $stack) = @_;
    
    $self->notice("Adding $archive");

    my $dist;
    if (my $dupe = $self->_check_for_duplicate($archive)) {
        $self->warning("Archive $archive is the same as $dupe -- using $dupe instead");
        $dist = $dupe;
    }
    else {
        $self->notice("Adding distribution archive $archive");
        $dist = $self->repo->add_distribution(archive => $archive, author => $self->author);
    }

    $dist->register(stack => $stack, pin => $self->pin);
    $self->repo->pull_prerequisites(dist => $dist, stack => $stack) unless $self->no_recurse;
    
    return $dist;
}

#------------------------------------------------------------------------------

sub _check_for_duplicate {
    my ($self, $archive) = @_;

    my $sha256 = sha256($archive);
    my $dupe = $self->repo->get_distribution(sha256 => $sha256);

    return if not $dupe;
    return $dupe if $archive->basename eq $dupe->archive;

    throw "Archive $archive is the same as $dupe but with different name";
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Add - Add a local distribution into the repository

=head1 VERSION

version 0.065_01

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
