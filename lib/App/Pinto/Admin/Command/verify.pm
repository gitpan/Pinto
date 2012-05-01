package App::Pinto::Admin::Command::verify;

# ABSTRACT: report distributions that are missing

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::verify - report distributions that are missing

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir verify

=head1 DESCRIPTION

This command reports distributions that are defined in the repository
database, but the archives are not actually present.  This could occur
when L<Pinto> aborts unexpectedly due to an exception or you terminate
a command prematurely.

At the moment, it isn't clear how to fix this situation.  In a future
release you might be able to replace the archive for the distribution.
But for now, this command simply lets you know if something has gone
wrong in your repository.

=head1 COMMAND ARGUMENTS

None

=head1 COMMAND OPTIONS

None

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

