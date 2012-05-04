# ABSTRACT: Install packages from the repository

package Pinto::Action::Install;

use Moose;

use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.040_002'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Interface::Action::Install );

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    # Write index to a temp location
    my $temp_index_fh = File::Temp->new;
    my $stack = $self->repos->get_stack(name => $self->stack);
    $self->repos->write_index(stack => $stack, handle => $temp_index_fh);

    # Wire cpanm to our repo
    my $opts = $self->cpanm_options;
    $opts->{'mirror-only'}  = undef;
    $opts->{'mirror-index'} = $temp_index_fh->filename;
    $opts->{mirror}         = 'file://' . $self->repos->root->absolute;

    # Process other cpanm options
    my @cpanm_opts;
    for my $opt ( keys %{ $opts } ){
        my $dashes = (length $opt == 1) ? '-' : '--';
        my $dashed_opt = $dashes . $opt;
        my $opt_value = $opts->{$opt};
        push @cpanm_opts, $dashed_opt;
        push @cpanm_opts, $opt_value if defined $opt_value && length $opt_value;
    }

    # Run cpanm
    $self->debug(join ' ', 'Running:', $self->cpanm_exe, @cpanm_opts);
    0 == system($self->cpanm_exe, @cpanm_opts, @{ $self->targets })
      or throw "Installation failed.  See the cpanm build log for details";

    return $self->result;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Install - Install packages from the repository

=head1 VERSION

version 0.040_002

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
