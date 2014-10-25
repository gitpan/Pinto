# ABSTRACT: Something that fetches remote files

package Pinto::Role::FileFetcher;

use Moose::Role;
use MooseX::MarkAsMethods (autoclean => 1);

use File::Temp;
use Path::Class;
use LWP::UserAgent;

use Pinto::Util qw(itis debug);
use Pinto::Exception qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.065_03'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has ua => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    lazy    => 1,
    builder => '_build_ua',
);

#------------------------------------------------------------------------------


sub fetch {
    my ($self, %args) = @_;

    my $from     = $args{from};
    my $from_uri = _make_uri($from);
    my $to       = itis($args{to}, 'Path::Class') ? $args{to} : file($args{to});

    debug("Skipping $from: already fetched to $to") and return 0 if -e $to;

    $to->parent->mkpath if not -e $to->parent;
    my $has_changed = $self->_fetch($from_uri, $to);

    return $has_changed;
}

#------------------------------------------------------------------------------


sub fetch_temporary {
    my ($self, %args) = @_;

    my $url  = URI->new($args{url})->canonical();
    my $path = Path::Class::file( $url->path() );
    return $path if $url->scheme() eq 'file';

    my $base     = $path->basename();
    my $tempdir  = File::Temp::tempdir(CLEANUP => 1);
    my $tempfile = Path::Class::file($tempdir, $base);

    $self->fetch(from => $url, to => $tempfile);

    return Path::Class::file($tempfile);
}

#------------------------------------------------------------------------------

sub _fetch {
    my ($self, $url, $to) = @_;

    debug("Fetching $url");

    my $result = eval { $self->ua->mirror($url, $to) }
        or throw $@;

    if ($result->is_success()) {
        return 1;
    }
    elsif ($result->code() == 304) {
        return 0;
    }
    else {
        throw "Failed to fetch $url: " . $result->status_line;
    }

    # Should never get here
}

#------------------------------------------------------------------------------

sub _build_ua {
    my ($self) = @_;

    # TODO: Do we need to make some of this configurable?
    my $agent = sprintf "%s/%s", ref $self, 'VERSION';
    my $ua = LWP::UserAgent->new( agent      => $agent,
                                  env_proxy  => 1,
                                  keep_alive => 5 );

    return $ua;
}

#------------------------------------------------------------------------------

sub _make_uri {
    my ($it) = @_;

    return $it
        if itis($it, 'URI');

    return URI::file->new( $it->absolute )
        if itis($it, 'Path::Class::File');

    return URI::file->new( file($it)->absolute )
        if -e $it;

    return URI->new($it);
}

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::FileFetcher - Something that fetches remote files

=head1 VERSION

version 0.065_03

=head1 METHODS

=head2 fetch(from => 'http://someplace' to => 'some/path')

Fetches the file located at C<from> to the file located at C<to>, if
the file at C<from> is newer than the file at C<to>.  If the
intervening directories do not exist, they will be created for you.
Returns a true value if the file has changed, returns false if it has
not changed.  Throws and exception if anything goes wrong.

The C<to> argument can be either a L<URI> or L<Path::Class::File>
object, or a string that represents either of those.  The C<from>
attribute can be a L<Path::Class::File> object or a string that
represents one.

=head2 fetch_temporary(url => 'http://someplace')

Fetches the file located at the C<url> to a file in a temporary
directory.  The file will have the same basename as the C<url>.
Returns a L<Path::Class::File> that points to the new file.  Throws
and exception if anything goes wrong.  Note the temporary directory
and all its contents will be deleted when the process terminates.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
