package Pinto::Action::Clean;

# ABSTRACT: Remove all outdated distributions from the repository

use Moose;
use MooseX::Types::Moose qw(Bool);

use List::MoreUtils qw(none);
use IO::Interactive;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.030'; # VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has confirm => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------
# Methods

override execute => sub {
    my ($self) = @_;

    my $outdated = $self->_select_outdated_distributions();
    my $removed  = 0;

    while ( my $dist = $outdated->next() ) {

        if ( $self->confirm() && IO::Interactive::is_interactive() ) {
            next if not $self->_prompt_for_confirmation($dist);
        }

        $self->info("Removing distribution $dist");
        $self->repos->remove_distribution($dist);
        $self->add_message( "Removed outdated distribution $dist" );
        $removed++;
    }

    return $removed;
};

#------------------------------------------------------------------------------

sub _select_outdated_distributions {
    my ($self) = @_;

    # TODO: This operation is pretty slow.  Find a way to make it
    # faster (i.e. smarter query, slurp and filter).

    my $attrs = { prefetch => 'packages', order_by => {-asc => 'path'} };
    my $rs = $self->repos->select_distributions(undef, $attrs);

    my @outdated;
    while ( my $dist = $rs->next() ) {
        my @packages = $dist->packages->all();
        push @outdated, $dist if none { $_->is_latest() } @packages;
    }

    my $new_rs = $rs->result_source->resultset();
    $new_rs->set_cache(\@outdated);

    return $new_rs;

}

# TODO: Do not clean the following...
# Latest version of any foreign pkg that is blocked by a local pkg
# Latest version of any pkg that is blocked by a pin

#------------------------------------------------------------------------------

sub _prompt_for_confirmation {
    my ($self, $archive) = @_;

    my $answer = '';
    until ($answer =~ m/^[yn]$/ix) {
        print "Remove distribution $archive? [Y/N]: ";
        chomp( $answer = uc <STDIN> );
    }

    return $answer eq 'Y';
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Clean - Remove all outdated distributions from the repository

=head1 VERSION

version 0.030

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
