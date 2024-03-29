# ABSTRACT:  Interact with a remote Pinto repository

package Pinto::Remote;

use Moose;
use MooseX::StrictConstructor;
use MooseX::MarkAsMethods ( autoclean => 1 );
use MooseX::Types::Moose qw(Maybe Str);

use Try::Tiny;
use LWP::UserAgent;

use Pinto::Chrome::Term;
use Pinto::Remote::Action;
use Pinto::Constants qw(:server);
use Pinto::Util qw(throw current_username);
use Pinto::Types qw(Uri);

#-------------------------------------------------------------------------------

our $VERSION = '0.09996'; # VERSION

#------------------------------------------------------------------------------

with qw(Pinto::Role::Plated Pinto::Role::UserAgent);

#------------------------------------------------------------------------------

has root => (
    is      => 'ro',
    isa     => Uri,
    default => $ENV{PINTO_REPOSITORY_ROOT},
    coerce  => 1,
);

has username => (
    is      => 'ro',
    isa     => Str,
    default => current_username,
);

has password => (
    is  => 'ro',
    isa => Maybe [Str],
);

#------------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args = $class->$orig(@_);

    # Grrr.  Gotta avoid passing undefs to Moose
    my @chrome_attrs = qw(verbose quiet color);
    my %chrome_args = map { $_ => delete $args->{$_} }
        grep { exists $args->{$_} } @chrome_attrs;

    $args->{chrome} ||= Pinto::Chrome::Term->new(%chrome_args);

    return $args;
};

#------------------------------------------------------------------------------


sub run {
    my ( $self, $action_name, @args ) = @_;

    # Divert all warnings through our chrome
    local $SIG{__WARN__} = sub { $self->warning($_) for @_ };

    my $action_args = ( @args == 1 and ref $args[0] eq 'HASH' ) ? $args[0] : {@args};

    my $result = try {

        my $action_class = $self->load_class_for_action( name => $action_name );

        my $action = $action_class->new(
            name     => $action_name,
            args     => $action_args,
            root     => $self->root,
            username => $self->username,
            password => $self->password,
            chrome   => $self->chrome,
        );

        $action->execute;
    }
    catch {
        $self->error($_);
        Pinto::Result->new->failed( because => $_ );
    };

    return $result;
}

#------------------------------------------------------------------------------

sub load_class_for_action {
    my ( $self, %args ) = @_;

    my $action_name = $args{name}
        or throw 'Must specify an action name';

    my $action_baseclass = __PACKAGE__ . '::Action';
    my $action_subclass  = __PACKAGE__ . '::Action::' . ucfirst $action_name;

    my $subclass_did_load = Class::Load::try_load_class($action_subclass);
    my $action_class = $subclass_did_load ? $action_subclass : $action_baseclass;

    Class::Load::load_class($action_class);

    return $action_class;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Remote - Interact with a remote Pinto repository

=head1 VERSION

version 0.09996

=head1 SYNOPSIS

See L<pinto> to create and manage a Pinto repository.

See L<pintod> to allow remote access to your Pinto repository.

See L<Pinto::Manual> for more information about the Pinto tools.

=head1 DESCRIPTION

Pinto::Remote is the cousin of L<Pinto>.  It provides the same API,
but instead of running Actions against a local repository, it just
sends the Action parameters to a L<pintod> server that invokes Pinto
on the remote host.

If you are using the L<pinto> application, it will automatically load
either Pinto or Pinto::Remote depending on whether your repository
root looks like a local directory path or a remote URI.

=head1 METHODS

=head2 run( $action_name => %action_args )

Loads the Action subclass for the given C<$action_name> and constructs
an object using the given C<$action_args>.  If the subclass
C<Pinto::Remote::Action::$action_name> does not exist, then it falls
back to the L<Pinto::Remote::Action> base class.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
