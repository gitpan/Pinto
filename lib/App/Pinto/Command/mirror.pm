package App::Pinto::Command::mirror;

# ABSTRACT: get the latest archives from a CPAN mirror

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.006'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    return (
        [ 'force'     => 'Force update, even if indexes appear unchanged' ],
        [ 'mirror=s'  => 'URL of a CPAN mirror (or another Pinto repository)' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;
    $self->usage_error('Arguments are not allowed') if @{ $args };
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;
    $self->pinto( $opts )->mirror();
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Command::mirror - get the latest archives from a CPAN mirror

=head1 VERSION

version 0.006

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
