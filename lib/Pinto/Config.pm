package Pinto::Config;

# ABSTRACT: User configuration for Pinto

use Moose;

use Carp;
use Config::Tiny;
use File::HomeDir;
use Path::Class;

#------------------------------------------------------------------------------

our $VERSION = '0.002'; # VERSION

#------------------------------------------------------------------------------


has 'profile' => (
    is           => 'ro',
    isa          => 'Str',
);

#------------------------------------------------------------------------------


sub BUILD {
    my ($self, $args) = @_;

    # TODO: Rewrite all this.  It sucks!
    # TODO: Decide where to do configuration validation

    my $profile = $self->profile() || _find_profile();
    croak "$profile does not exist" if defined $profile and not -e $profile;

    my $params = $profile ? Config::Tiny->read( $profile )->{_} : {};

    croak "Failed to read profile $profile: " . Config::Tiny->errorstr()
        if not $params;

    $self->{$_} = $params->{$_} for keys %{ $params };
    $self->{$_} = $args->{$_}   for keys %{ $args   };

    return $self;
}

#------------------------------------------------------------------------------


sub get_required {
    my ($self, $key) = @_;

    croak 'Must specify a configuration key'
        if not $key;

    die "Parameter '$key' is required in your configuration.\n"
        if not exists $self->{$key};

    return $self->{$key};
}

#------------------------------------------------------------------------------


sub get {
    my ($self, $key) = @_;

    croak 'Must specify a configuration key'
        if not $key;

    return $self->{$key};
}

#------------------------------------------------------------------------------

sub _find_profile {
    return $ENV{PERL_PINTO} if defined $ENV{PERL_PINTO};
    my $home_file = file(File::HomeDir->my_home(), '.pinto', 'config.ini');
    return $home_file if -e $home_file;
    return;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Config - User configuration for Pinto

=head1 VERSION

version 0.002

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=head1 ATTRIBUTES

=head2 profile

Returns the path to your L<Pinto> configuration file.  If you do not
specify one through the constructor, then we look at C<$ENV{PINTO}>,
then F<~/.pinto/config.ini>.  If the config file does not exist in any
of those locations, then you will get an empty config.

=head1 METHODS

=head2 get_required($key)

Returns the configuration value assocated with the given C<$key>.  If
that value is not defined, then an exception is thrown.

=head2 get($key)

Returns the configuration value associated with the given C<$key>.  The
value may be undefined.

=for Pod::Coverage BUILD

Internal, not documented

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

