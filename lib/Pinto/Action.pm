# ABSTRACT: Base class for all Actions

package Pinto::Action;

use Moose;
use MooseX::Types::Moose qw(Str);
use IO::Pipe;

use Pinto::Result;
use Pinto::Exception;
use Pinto::Types qw(Io);
use Pinto::Util qw(is_interactive);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.065'; # VERSION

#------------------------------------------------------------------------------

with qw( Pinto::Role::Configurable
         Pinto::Role::Loggable );

#------------------------------------------------------------------------------


has repo  => (
    is       => 'ro',
    isa      => 'Pinto::Repository',
    required => 1,
);


has out => (
    is      => 'ro',
    isa     => Io,
    coerce  => 1,
    lazy    => 1,
    builder => '_build_out',
);


has result => (
    is       => 'ro',
    isa      => 'Pinto::Result',
    default  => sub { Pinto::Result->new },
    init_arg => undef,
    lazy     => 1,
);

#------------------------------------------------------------------------------

sub execute { throw 'Abstract method' }

#------------------------------------------------------------------------------

sub say {
    my ($self, $message) = @_;
    return print {$self->out} $message . "\n";
}

#------------------------------------------------------------------------------

sub _build_out {
    my ($self) = @_;

    my $stdout = [fileno(STDOUT), '>'];
    my $pager = $ENV{PINTO_PAGER} || $ENV{PAGER};

    return $stdout if not is_interactive;
    return $stdout if not $pager;

    open my $pager_fh, q<|->, $pager
        or throw "Failed to open pipe to pager $pager: $!";

    return bless $pager_fh, 'IO::Handle'; # HACK!
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action - Base class for all Actions

=head1 VERSION

version 0.065

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
