package Pinto::Util::Svn;

# ABSTRACT: Utility functions for working with Subversion

use strict;
use warnings;

use Carp qw(carp croak);
use List::MoreUtils qw(firstidx);
use Path::Class;
use IPC::Run;

#--------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#--------------------------------------------------------------------------


sub svn_mkdir {
    my %args = @_;
    my $url = $args{url};
    my $dir = $args{dir};
    my $message = $args{message} || 'NO MESSAGE GIVEN';

    if ( $url and not svn_ls(url => $url) ) {
        return _svn( command => [qw(mkdir --parents -m), $message, $url]);
    }
    elsif ($dir and not -e $dir) {
        return _svn( command => [qw(mkdir --parents), $dir] );
    }

    return 1;
}

#--------------------------------------------------------------------------


sub svn_ls {
    my %args = @_;
    my $url  = $args{url};

    return _svn( command => ['ls', $url], croak => 0 );
}

#--------------------------------------------------------------------------


sub svn_checkout {
    my %args = @_;
    my $url  = $args{url};
    my $to   = $args{to};

    return _svn( command => ['co', $url, $to] )
        if not -e $to and svn_mkdir(url => $url);

    croak "$to already exists but is not an svn working copy. ",
        "Perhaps you should delete $to first or use a different directory"
            if not _is_svn_working_copy(directory => $to);

    my $wc_url = _url_for_wc_path(path => $to);

    croak "$to should be a working copy of $url but is actually of $wc_url"
            if $url ne $wc_url;

    return _svn( command => ['up', $to] );
}

#--------------------------------------------------------------------------


sub svn_schedule {
    my %args = @_;
    my $starting_path = $args{path};

    my $buffer = '';
    _svn(command => ['status', $starting_path], buffer => \$buffer);

    for my $line (split / \n /x, $buffer) {

        $line =~ /^ (\S) \s+ (\S+) $/x
            or croak "Unable to parse svn status: $line";

        my ($status, $path) = ($1, $2);

        if ($status eq '?') {
            svn_add(path => $path);
        }
        elsif ($status eq '!') {
            svn_delete(path => $path);
        }
        elsif ($status =~ /^ [AMD] $/x) {
            # Do nothing!
        }
        else {
            # TODO: Decide how to handle other statuses (e.g. locked).
            carp "Unexpected status: $status for file $path";
        }
    }

    return 1;
}

#--------------------------------------------------------------------------


sub svn_add {
    my %args = @_;
    my $path = $args{path};

    return _svn( command => ['add', $path] );
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
    return _svn(command => [qw(commit -m), $message, @paths] );
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

sub _url_for_wc_path {
    my %args = @_;
    my $path = $args{path};

    my $buffer = '';
    _svn( command => ['info', $path], buffer => \$buffer);

    $buffer =~ /^ URL: \s+ (\S+) $/xm
        or croak "Unable to parse svn info: $buffer";

    return $1;
}

#--------------------------------------------------------------------------

sub _is_svn_working_copy {
    my %args = @_;
    my $directory = $args{directory};

    return -e dir($directory, '.svn');
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
        unshift @{$command}, 'svn';
        $ok = IPC::Run::run($command, \my($in), $buffer, $buffer);
    }

    if ($croak and not $ok) {

        # Truncate the '-m MESSAGE' arguments, for readability
        if ( (my $dash_m_offset = firstidx {$_ eq '-m'} @{ $command }) > 0 ) {
            splice @{ $command }, $dash_m_offset + 1, 1, q{'...'};
        }

        my $command_string = join ' ', @{ $command };
        croak "Command failed: $command_string\n" . ${ $buffer };
    }

    return $ok;
}

#--------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Util::Svn - Utility functions for working with Subversion

=head1 VERSION

version 0.021

=head1 FUNCTIONS

=head2 svn_mkdir(url => 'http://somewhere')

Given a URL that is presumed to be a location within a Subversion
repository, creates a directory at that location.  Any intervening
directories will be created for you.  If the directory already exists,
an exception will be thrown.

=head2 svn_ls(url => 'http://somewhere')

Given a URL that is presumed to be a location within a Subversion
repository, returns true if that location actually exists.

=head2 svn_checkout(url => 'http://somewhere' to => '/some/path')

Checks out the specified URL to the specified path.  If the URL does
not exist in the repository, it will be created for you.  If the path
already exists and it is a working copy for URL, an update will be
performed instead.

=head2 svn_schedule(path => '/some/path')

Given a path to a directory or file within a Subversion working copy,
recursively scans the directory for new or missing files and schedules
them or addition or deletion from the repository.  Any new file is
added, and any missing file is deleted.

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
server-side copy and does no affect on any working copy.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
