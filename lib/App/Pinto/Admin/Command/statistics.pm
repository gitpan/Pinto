package App::Pinto::Admin::Command::statistics;

# ABSTRACT: report statistics about the repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.040_001'; # VERSION

#------------------------------------------------------------------------------

sub command_names { return qw( statistics stats ) }

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

 my $usage =  <<"END_USAGE";
%c --root=PATH $command
END_USAGE

    chomp $usage;
    return $usage;
}


#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Admin::Command::statistics - report statistics about the repository

=head1 VERSION

version 0.040_001

=head1 SYNOPSIS

  pinto-admin --root=/some/dir statistics

=head1 DESCRIPTION

This command reports some statistics about the repository.  It is
currently only reports information about the master stack.

=head1 COMMAND ARGUMENTS

None.

=head1 COMMAND OPTIONS

None.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

