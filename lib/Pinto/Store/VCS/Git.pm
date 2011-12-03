package Pinto::Store::VCS::Git;

# ABSTRACT: Store your Pinto repository with Git

use Moose;

use Carp;

extends 'Pinto::Store::VCS';

#-------------------------------------------------------------------------------

our $VERSION = '0.025_003'; # VERSION

#-------------------------------------------------------------------------------

override initialize => sub {
    croak __PACKAGE__ . 'is not implemented yet';
    # git clone or git pull
};

#-------------------------------------------------------------------------------

override commit => sub {
    croak __PACKAGE__ . 'is not implemented yet';
    # git commit and push
};

#-------------------------------------------------------------------------------

override tag => sub {
    croak __PACKAGE__ . 'is not implemented yet';
    # git tag
};

#-------------------------------------------------------------------------------

override add_file => sub {
    croak __PACKAGE__ . 'is not implemented yet';
    # git add
};

#-------------------------------------------------------------------------------

override remove_file => sub {
    croak __PACKAGE__ . 'is not implemented yet';
    # git rm
};

#-------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Store::VCS::Git - Store your Pinto repository with Git

=head1 VERSION

version 0.025_003

=head1 DESCRIPTION

This module is Not yet implemented.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

