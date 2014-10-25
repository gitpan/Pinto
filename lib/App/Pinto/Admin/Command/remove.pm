package App::Pinto::Admin::Command::remove;

# ABSTRACT: remove local distributions from the repository

use strict;
use warnings;

use Pinto::Util;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.024'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw( remove rm delete del ) }

#------------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'author=s'    => 'Your (alphanumeric) author ID' ],
        [ 'message|m=s' => 'Prepend a message to the VCS log' ],
        [ 'nocommit'    => 'Do not commit changes to VCS' ],
        [ 'noinit'      => 'Do not pull/update from VCS' ],
        [ 'tag=s'       => 'Specify a VCS tag name' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

 my $usage =  <<"END_USAGE";
%c --repos=PATH $command [OPTIONS] DISTRIBUTION_NAME ...
%c --repos=PATH $command [OPTIONS] < LIST_OF_DISTRIBUTION_NAMES
END_USAGE

    chomp $usage;
    return $usage;
}


#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my @args = @{$args} ? @{$args} : Pinto::Util::args_from_fh(\*STDIN);
    return 0 if not @args;

    $self->pinto->new_action_batch( %{$opts} );
    $self->pinto->add_action('Remove', %{$opts}, dist_name => $_) for @args;
    my $result = $self->pinto->run_actions();

    return $result->is_success() ? 0 : 1;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::remove - remove local distributions from the repository

=head1 VERSION

version 0.024

=head1 SYNOPSIS

  pinto-admin --repos=/some/dir remove [OPTIONS] DISTRIBUTION_NAME ...
  pinto-admin --repos=/some/dir remove [OPTIONS] < LIST_OF_DISTRIBUTION_NAMES

=head1 DESCRIPTION

This command removes a local distribution from the repository.  You
cannot remove foreign distributions that were pulled in from another
repository using the C<update> command (however you can mask them by
adding your own versions).

=head1 COMMAND ARGUMENTS

Arguments to this command are the names of the distributions you wish
to remove.  You must specify the complete distribution name, including
version number and extension.  The precise identity of the
distribution that will be removed depends on who you are.  So if you
are C<JOE> and you ask to remove C<Foo-1.0.tar.gz> then you are really
asking to remove F<J/JO/JOE/Foo-1.0.tar.gz>.

To remove a distribution that was added by another author, use the
C<--author> option to change who you are.  Or you can just
explicitly specify the full identity of the distribution.  So the
following two examples are equivalent:

  $> pinto-admin --repos=/some/dir remove --author=SUSAN Foo-1.0.tar.gz
  $> pinto-admin --repos=/some/dir remove S/SU/SUSAN/Foo-1.0.tar.gz

You can also pipe arguments to this command over STDIN.  In that case,
blank lines and lines that look like comments (i.e. starting with "#"
or ";") will be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --author=NAME

Sets your identity as a distribution author.  The NAME can only be
alphanumeric characters only (no spaces) and will be forced to
uppercase.  The default is your username.

=item --message=MESSAGE

Prepends the MESSAGE to the VCS log message that L<Pinto> generates.
This is only relevant if you are using a VCS-based storage mechanism
for L<Pinto>.

=item --nocommit

Prevents L<Pinto> from committing changes in the repository to the VCS
after the operation.  This is only relevant if you are
using a VCS-based storage mechanism.  Beware this will leave your
working copy out of sync with the VCS.  It is up to you to then commit
or rollback the changes using your VCS tools directly.  Pinto will not
commit old changes that were left from a previous operation.

=item --noinit

Prevents L<Pinto> from pulling/updating the repository from the VCS
before the operation.  This is only relevant if you are using a
VCS-based storage mechanism.  This can speed up operations
considerably, but should only be used if you *know* that your working
copy is up-to-date and you are going to be the only actor touching the
Pinto repository within the VCS.

=item --tag=NAME

Instructs L<Pinto> to tag the head revision of the repository at NAME.
This is only relevant if you are using a VCS-based storage mechanism.
The syntax of the NAME depends on the type of VCS you are using.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

