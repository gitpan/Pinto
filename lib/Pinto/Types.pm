package Pinto::Types;

# ABSTRACT: Moose types used within Pinto

use strict;
use warnings;

use MooseX::Types -declare => [ qw( AuthorID URI Dir File IO) ];
use MooseX::Types::Moose qw( Str ScalarRef ArrayRef FileHandle Object Int);

use URI;
use Path::Class::Dir;
use Path::Class::File;
use File::HomeDir;
use IO::String;
use IO::Handle;
use IO::File;

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.012'; # VERSION

#-----------------------------------------------------------------------------

subtype AuthorID,
    as Str,
    where { not m/[^A-Z0-9-]/x },
    message { "The author ($_) must be alphanumeric" };

coerce AuthorID,
    from Str,
    via  { uc $_ };

#-----------------------------------------------------------------------------

class_type URI, {class => 'URI'};

coerce URI,
    from Str,
    via { 'URI'->new($_) };

#-----------------------------------------------------------------------------

subtype Dir, as 'Path::Class::Dir';

coerce Dir,
    from Str,             via { Path::Class::Dir->new( expand_tilde($_) ) },
    from ArrayRef,        via { Path::Class::Dir->new( expand_tilde( @{$_} ) ) };

#-----------------------------------------------------------------------------

subtype File, as 'Path::Class::File';

coerce File,
    from Str,             via { Path::Class::File->new( expand_tilde($_) ) },
    from ArrayRef,        via { Path::Class::File->new( @{$_} ) };

#-----------------------------------------------------------------------------

sub expand_tilde {
    my (@paths) = @_;

    $paths[0] =~ s|\A ~ (?= \W )|File::HomeDir->my_home()|xe;

    return @paths;
}

#-----------------------------------------------------------------------------

subtype IO, as Object;

coerce IO,
    from Str,        via { my $fh = IO::File->new(); $fh->open($_);   return $fh },
    from File,       via { my $fh = IO::File->new(); $fh->open("$_"); return $fh },
    from ArrayRef,   via { IO::Handle->new_from_fd( @$_ ) },
    from ScalarRef,  via { IO::String->new( ${$_} ) };

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Types - Moose types used within Pinto

=head1 VERSION

version 0.012

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__