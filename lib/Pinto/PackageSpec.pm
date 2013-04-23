# ABSTRACT: Specifies a package by name and version

package Pinto::PackageSpec;

use Moose;
use MooseX::MarkAsMethods (autoclean => 1);
use MooseX::Types::Moose qw(Str);

use Module::CoreList;
use English qw(-no_match_vars);

use Pinto::Types qw(Version);
use Pinto::Util qw(throw);

use version;
use overload ('""' => 'to_string');

#------------------------------------------------------------------------------

our $VERSION = '0.079_04'; # VERSION

#------------------------------------------------------------------------------

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has version => (
    is      => 'ro',
    isa     => Version,
    coerce  => 1,
    default => sub { version->parse(0) }
);

#------------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my @args = @_;
    if (@args == 1 and not ref $args[0]) {
        my ($name, $version) = split m{~}x, $_[0], 2;
        @args = (name => $name, version => $version || 0);
    }

    return $class->$orig(@args);
};

#------------------------------------------------------------------------------


sub is_core {
    my ($self, %args) = @_;

    ## no critic qw(PackageVar);

    my $pv = version->parse($args{in}) || $PERL_VERSION;
    my $core_modules = $Module::CoreList::version{ $pv->numify + 0 };

    throw "Invalid perl version $pv" if not $core_modules;

    return 0 if not exists $core_modules->{$self->name};

    # on some perls, we'll get an 'uninitialized' warning when
    # the $core_version is undef.  So force to zero in that case
    my $core_version = $core_modules->{$self->name} || 0;

    return 0 if $self->version > $core_version;
    return 1;
}

#-------------------------------------------------------------------------------


sub is_perl {
    my ($self) = @_;

    return $self->name eq 'perl' ? 1 : 0;
}

#-------------------------------------------------------------------------------


sub to_string {
    my ($self) = @_;
    return sprintf '%s~%s', $self->name, $self->version->stringify;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::PackageSpec - Specifies a package by name and version

=head1 VERSION

version 0.079_04

=head1 METHODS

=head2 is_core

=head2 is_core(in => $version)

Returns true if this package is satisfied by the perl core as-of a particular
version.  If the version is not specified, it defaults to whatever version
you are using now.

=head2 is_perl()

Returns true if this package is perl itself.

=head2 to_string()

Serializes this PackageSpec to its string form.  This method is called
whenever the PackageSpec is evaluated in string context.

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
