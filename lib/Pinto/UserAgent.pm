package Pinto::UserAgent;

# ABSTRACT: Thin wrapper around LWP::UserAgent

use Moose;

use Carp;
use Path::Class;
use LWP::UserAgent;

#------------------------------------------------------------------------------

our $VERSION = '0.001'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has _ua => (
    is       => 'ro',
    isa      => 'LWP::UserAgent',
    builder  => '_build_ua',
    init_arg => undef,
);

#------------------------------------------------------------------------------
# Roles

#with 'Pinto::Log';

#------------------------------------------------------------------------------


sub mirror {
    my ($self, %args) = @_;
    my $url = $args{url};
    my $to  = $args{to};

    $to = file($to) if not eval {$to->isa('Path::Class')};
    $to->dir()->mkpath();  # TODO: set mode & verbosity

    my $ua = $self->_ua();
    my $result = $ua->mirror($url, $to);

    if ($result->is_success()) {
        return 1;
    }
    elsif($result->code == 304) {
        return 0;
    }
    else{
        croak "Mirror of $url to $to failed with status: " . $result->code();
    }
}

#------------------------------------------------------------------------------

sub _build_ua {
    my ($self) = @_;

    #$DB::single = 1;
    my $agent = sprintf "%s/%s", ref $self, 'VERSION';
    my $ua = LWP::UserAgent->new(
        agent      => $agent,
        env_proxy  => 1,
        keep_alive => 5,
    );

    return $ua;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::UserAgent - Thin wrapper around LWP::UserAgent

=head1 VERSION

version 0.001

=head1 METHODS

=head2 mirror(url => 'http://someplace' to => 'some/path')

Mirrors the file located at the C<url> to the file located at C<to>.
If the intervening directories do not exist, they will be created for
you.  Returns a true value if the file has changed, returns false if
it has not changed.  Throws and exception if anything goes wrong.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
