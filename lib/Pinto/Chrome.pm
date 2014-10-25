# ABSTRACT: Base class for interactive interfaces

package Pinto::Chrome;

use Moose;
use MooseX::Types::Moose qw(Int Bool);

use Pinto::Util qw(user_colors);
use Pinto::Exception qw(throw);

#-----------------------------------------------------------------------------

our $VERSION = '0.065_03'; # VERSION

#-----------------------------------------------------------------------------

has verbose => (
    is      => 'ro',
    isa     => Int,
    default => 0,
);


has quiet   => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#-----------------------------------------------------------------------------

sub show { throw 'Abstract method' }

#-----------------------------------------------------------------------------

sub diag { throw 'Abstract method' }

#-----------------------------------------------------------------------------

sub show_progress { throw 'Abstract method' }

#-----------------------------------------------------------------------------

sub progress_done { throw 'Abstract method' }

#-----------------------------------------------------------------------------

sub should_display {
    my ($self, $level) = @_;

    return 1 if $level == 0;           # Always, always display errors
    return 0 if $self->quiet;          # Don't display anything else if quiet
    return $self->verbose + 1 >= $level;
}

#-----------------------------------------------------------------------------

sub levels { return qw(error warning notice info) }

#-----------------------------------------------------------------------------

my @levels = __PACKAGE__->levels;
__generate_method($levels[$_], $_) for (0..$#levels);

#-----------------------------------------------------------------------------

sub __generate_method {
    my ($name, $level) = @_;

    my $template = <<'END_METHOD';
sub %s {
    my ($self, $msg, $opts) = @_;
    return unless $self->should_display(%s);
    $self->diag($msg, $opts);
}
END_METHOD

    eval sprintf $template, $name, $level;
    croak $@ if $@;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Chrome - Base class for interactive interfaces

=head1 VERSION

version 0.065_03

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
