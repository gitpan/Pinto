package Pinto::Role::Authored;

# ABSTRACT: Something that has an author

use Moose::Role;

use English qw(-no_match_vars);
use Pinto::Types 0.017 qw(AuthorID);
use Pinto::Exception::NoAuthor;

#------------------------------------------------------------------------------

our $VERSION = '0.023'; # VERSION

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
    if (my $name = getpwuid($REAL_USER_ID)) {
        return uc $name;
    }

    # Otherwise, we are hosed!
    Pinto::Exception::NoAuthor->throw( 'Unable to determine your user name' );

}

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Role::Authored - Something that has an author

=head1 VERSION

version 0.023

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

