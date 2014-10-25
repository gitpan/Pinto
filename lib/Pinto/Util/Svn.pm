package Pinto::Util::Svn;

# ABSTRACT: Utility functions for working with Subversion

use strict;
use warnings;

use List::MoreUtils qw(firstidx);
use Path::Class;
use IPC::Run;

use Pinto::Exceptions qw(throw_fatal);

#--------------------------------------------------------------------------

our $VERSION = '0.032'; # VERSION

#--------------------------------------------------------------------------


sub svn_update {
    my %args = @_;
    my $dir  = $args{dir};

    return _svn( command => ['up', $dir] );
}

#--------------------------------------------------------------------------


sub svn_add {
    my %args = @_;

    my $path = $args{path};

    while (not _is_known_to_svn( $path->parent() ) ) {
        $path = $path->parent();
    }

    _svn( command => ['add', '--force', $path] );

    return $path;
}

#--------------------------------------------------------------------------


sub svn_remove {
    my %args  = @_;

    my $path  = $args{path};
    return if not -e $path;

    _svn( command => ['rm', '--force', $path] );

    while (my $parent = $path->parent() ) {
        last if not _all_scheduled_for_deletion($parent);
        _svn( command => ['rm', '--force', $parent] );
        $path = $parent;
    }

    return $path;
}

#--------------------------------------------------------------------------


sub svn_commit {
    my %args     = @_;
    my $paths    = $args{paths};
    my $message  = $args{message} || 'NO MESSAGE GIVEN';

    my @paths = ref $paths eq 'ARRAY' ? @{ $paths } : ($paths);
    my @args  = @paths < 128 ? @paths : ('--targets', _make_targets_file($paths));

    return _svn(command => [qw(commit -m), $message, @args] );
}

#--------------------------------------------------------------------------


sub svn_tag {
    my %args = @_;
    my $from    = $args{from};
    my $to      = $args{to};
    my $message = $args{message} || 'NO MESSAGE GIVEN';

    return _svn(command => [qw(cp --parents -m), $message, $from, $to]);
}

#--------------------------------------------------------------------------


sub location {
    my %args = @_;
    my $path = $args{path};

    my $buffer = '';
    _svn( command => ['info', $path], buffer => \$buffer);

    $buffer =~ /^ URL: \s+ (\S+) $/xm
        or throw_fatal "Unable to parse svn info: $buffer";

    return $1; ## no critic qw(Capture)
}

#--------------------------------------------------------------------------

sub _is_known_to_svn {
    my ($path) = @_;

    my $buffer = '';
    _svn( command => ['status', '--depth=empty', $path], buffer => \$buffer);

    return if $buffer  =~ m/is not a working copy/m;
    return not $buffer =~ m/^\? /mx;
}

#--------------------------------------------------------------------------

sub _all_scheduled_for_deletion {
    my ($directory) = @_;

    for my $child ($directory->children()) {
        next if $child->basename() eq '.svn';
        _svn(command => ['status', $child], buffer => \my $buffer);
        return 0 if not $buffer or $buffer =~ m/^ [^D] /xm;
    }

    return 1;
}

#--------------------------------------------------------------------------

sub _make_targets_file {
    my ($args) = @_;

    my $tempdir = File::Temp::tempdir(CLEANUP => 1);
    my $file    = dir( $tempdir )->file('args');
    my $fh      = $file->openw();
    print {$fh} "$_\n" for @{$args};
    close $fh;

    return $file;
}

#--------------------------------------------------------------------------

sub _svn {
    my %args = @_;
    my $command = $args{command};
    my $buffer  = $args{buffer} || \(my $anon = '');
    my $croak   = defined $args{croak} ? $args{croak} : 1;

    my $ok;

    {
        # When running in a server environment (like pinto-server),
        # $SIG{CHLD} may get set to 'IGNORE'.  But that fucks with
        # IPC::Run.  So we need to set it back here.

        local $SIG{CHLD} = 'DEFAULT';
        unshift @{$command}, _svn_exe();
        $ok = IPC::Run::run($command, \my($in), $buffer, $buffer);
    }

    if ($croak and not $ok) {

        # Truncate the '-m MESSAGE' arguments, for readability
        if ( (my $dash_m_offset = firstidx {$_ eq '-m'} @{ $command }) > 0 ) {
            splice @{ $command }, $dash_m_offset + 1, 1, q{'...'};
        }

        my $command_string = join ' ', @{ $command };
        throw_fatal "Command failed: $command_string\n" . ${ $buffer };
    }

    return $ok;
}

#--------------------------------------------------------------------------

sub _svn_exe { return 'svn' }

#--------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Util::Svn - Utility functions for working with Subversion

=head1 VERSION

version 0.032

=head1 FUNCTIONS

=head2 svn_update(dir => '/some/path')

Updates the working copy at the specified directory to the HEAD revision.

=head2 svn_add(path => '/some/path')

Schedules the specified path for addition to the repository.

=head2 svn_remove(path => $some_path)

Schedules the specified path (as a L<Path::Class>) for removal from
the repository.  Any directories above the path will also be removed
if all their children are scheduled for removal (i.e empty directories
will be removed).

=head2 svn_commit(paths => \@paths, message => 'Commit message')

Commits all the changes to the specified C<@paths>.

=head2 svn_tag(from => 'http://here', to => 'http://there')

Creates a tag by copying from one URL to another.  Note this is a
server-side copy and does not affect on any working copy.

=head2 location(path => '/some/path')

Returns the repository URL for the corresponding working copy path.  If
the path is not part of a working copy, an exception will be thrown.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
