# ABSTRACT: Filters core modules based on specific perl version

package Pinto::PrerequisiteFilter::Core;

use Moose;
use MooseX::MarkAsMethods (autoclean => 1);

use Module::CoreList;
use English qw(-no_match_vars);

use Pinto::Types qw(Version);
use Pinto::Exception qw(throw);

#------------------------------------------------------------------------------

our $VERSION = '0.065_02'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::PrerequisiteFilter );

#------------------------------------------------------------------------------

has perl_version => (
    is         => 'ro',
    isa        => Version,
    default    => sub { $PERL_VERSION },
    coerce     => 1,
);

#------------------------------------------------------------------------------

sub BUILD {
	my ($self) = @_;

    # version.pm doesn't always strip trailing zeros
	my $pv = $self->perl_version->numify + 0;

    throw "The perl_version ($pv) cannot be greater than this perl ($])"
    	if $pv > $];

   	throw "Unknown version of perl: $pv"
     	if not exists $Module::CoreList::version{$pv};  ## no critic (PackageVar)

    return $self;
}

#------------------------------------------------------------------------------

sub should_filter {
    my ($self, $prereq) = @_;

    my $pkg_name     = $prereq->name;
    my $perl_version = $self->perl_version->numify + 0;
    my $core_version = $Module::CoreList::version{$perl_version};  ## no critic (PackageVar)

    return 1 if $pkg_name eq 'perl';
    return 0 if not exists $core_version->{$pkg_name};
    return 1 if $core_version->{$pkg_name} >= $prereq->version;
    return 0;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::PrerequisiteFilter::Core - Filters core modules based on specific perl version

=head1 VERSION

version 0.065_02

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
