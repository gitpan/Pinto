package App::Pinto::Command::list;

# ABSTRACT: list the contents of the repository

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

our $VERSION = '0.002'; # VERSION

#------------------------------------------------------------------------------

sub opt_spec {
    return (
        [ "index:s"  => 'List the MASTER|LOCAL|REMOTE index' ],
    );
}

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opt, $args) = @_;

    $self->usage_error('Arguments are not allowed') if @{ $args };

    my $requested_type = $opt->{type} || 'MASTER';
    my %valid_types = map { $_ => 1 } qw(MASTER LOCAL REMOTE);
    $self->usage_error('--index is one of ' . join '|', sort keys %valid_types)
        if not defined $valid_types{$requested_type};
}

#------------------------------------------------------------------------------

sub execute {
    $DB::single = 1;
    my ($self, $opts, $args) = @_;
    $self->pinto()->list();
    return 0;
}

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

App::Pinto::Command::list - list the contents of the repository

=head1 VERSION

version 0.002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
