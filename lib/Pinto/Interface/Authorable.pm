package Pinto::Interface::Authorable;

# ABSTRACT: Something that has an author

use Moose::Role;

use Pinto::Types qw(AuthorID);
use Pinto::Exceptions qw(throw_fatal);

#------------------------------------------------------------------------------

our $VERSION = '0.027'; # VERSION

#------------------------------------------------------------------------------

has author => (
    is         => 'ro',
    isa        => AuthorID,
    coerce     => 1,
    lazy_build => 1,
);

#------------------------------------------------------------------------------

sub _build_author {                                  ## no critic (FinalReturn)

    # Look at typical environment variables
    for my $var ( qw(USERNAME USER LOGNAME) ) {
        return uc $ENV{$var} if $ENV{$var};
    }

    # Try using pwent.  Probably only works on *nix
    if (my $name = getpwuid($<)) {
        return uc $name;
    }

    # Otherwise, we are hosed!
    throw_fatal 'Unable to determine your user name';

}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Interface::Authorable - Something that has an author

=head1 VERSION

version 0.027

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

