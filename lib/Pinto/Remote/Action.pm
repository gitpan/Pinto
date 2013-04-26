# ABSTRACT: Base class for remote Actions

package Pinto::Remote::Action;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods (autoclean => 1);
use MooseX::Types::Moose qw(Str Maybe);

use URI;
use JSON;
use HTTP::Request::Common;

use Pinto::Result;
use Pinto::Constants qw(:server);
use Pinto::Types qw(Uri);

#------------------------------------------------------------------------------

our $VERSION = '0.081'; # VERSION

#------------------------------------------------------------------------------

with qw(Pinto::Role::Plated);

#------------------------------------------------------------------------------

has name      => (
    is        => 'ro',
    isa       => Str,
    required  => 1,
);


has root => (
    is       => 'ro',
    isa      => Uri,
    required => 1,
);


has args     => (
    is       => 'ro',
    isa      => 'HashRef',
    default  => sub { {} },
);


has username => (
    is       => 'ro',
    isa      => Str,
    required => 1
);


has password => (
    is       => 'ro',
    isa      => Maybe[ Str ],
    required => 1,
);


has ua        => (
    is        => 'ro',
    isa       => 'LWP::UserAgent',
    required  => 1,
);

#------------------------------------------------------------------------------


sub execute {
    my ($self) = @_;

    my $request = $self->_make_request;
    my $result  = $self->_send_request(req => $request);

    return $result;
}

#------------------------------------------------------------------------------

sub _make_request {
    my ($self, %args) = @_;

    my $action_name  = $args{name} || $self->name;
    my $request_body = $args{body} || $self->_make_request_body;

    my $url = URI->new( $self->root );
    $url->path_segments('', 'action', lc $action_name);

    my $request = POST( $url, Content_Type => 'form-data',
                              Content      => $request_body );

    if ( defined $self->password ) {
        $request->authorization_basic( $self->username, $self->password );
    }

    return $request;
}


#------------------------------------------------------------------------------

sub _make_request_body {
    my ($self) = @_;

    return [ $self->_chrome_args, $self->_pinto_args, $self->_action_args ];
}


#------------------------------------------------------------------------------

sub _chrome_args {
    my ($self) = @_;

    my $chrome_args = { verbose  => $self->chrome->verbose,
                        no_color => $self->chrome->no_color,
                        quiet    => $self->chrome->quiet };

    return ( chrome => encode_json($chrome_args) );

}

#------------------------------------------------------------------------------

sub _pinto_args {
    my ($self) = @_;

    my $pinto_args = { username  => $self->username };

    return ( pinto => encode_json($pinto_args) );
}

#------------------------------------------------------------------------------

sub _action_args {
    my ($self) = @_;

    my $action_args = $self->args;

    return ( action => encode_json($action_args) );
}

#------------------------------------------------------------------------------

sub _send_request {
    my ($self, %args) = @_;

    my $request = $args{req} || $self->_make_request;

    my $status   = 0;
    my $buffer   = '';

    # Currying in some extra args to the callback...
    my $callback = sub { $self->_response_callback(@_, \$status, \$buffer) };
    my $response = $self->ua->request($request, $callback, 128);

    if (not $response->is_success) {
        $self->error($response->content);
        return Pinto::Result->new(was_successful => 0);
    }

    return Pinto::Result->new(was_successful => $status);
}

#------------------------------------------------------------------------------

sub _response_callback {                  ## no critic qw(ProhibitManyArgs)
    my ($self, $data, $request, $proto, $status, $buffer) = @_;

    my $lines = '';
    $lines = $1 if (${ $buffer } .= $data) =~ s{^ (.*)\n }{}sx;

    for (split m{\n}x, $lines, -1) {

        if ($_ eq $PINTO_SERVER_STATUS_OK) {
            ${ $status } = 1;
        }
        elsif (m{^ \Q$PINTO_SERVER_DIAG_PREFIX\E (.*)}x) {
            print {$self->chrome->stderr} "$1\n";
        }
        else {
            print {$self->chrome->stdout} "$_\n";
        }
    }

    return 1;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Remote::Action - Base class for remote Actions

=head1 VERSION

version 0.081

=head1 METHODS

=head2 execute

Runs this Action on the remote server by serializing itself and
sending a POST request to the server.  Returns a L<Pinto::Result>.

=head1 CONTRIBUTORS

=over 4

=item *

Cory G Watson <gphat@onemogin.com>

=item *

Jakob Voss <jakob@nichtich.de>

=item *

Jeff <jeff@callahan.local>

=item *

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=item *

Jeffrey Thalhammer <jeff@imaginative-software.com>

=item *

Karen Etheridge <ether@cpan.org>

=item *

Michael G. Schwern <schwern@pobox.com>

=item *

Steffen Schwigon <ss5@renormalist.net>

=item *

Wolfgang Kinkeldei <wolfgang@kinkeldei.de>

=item *

Yanick Champoux <yanick@babyl.dyndns.org>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
