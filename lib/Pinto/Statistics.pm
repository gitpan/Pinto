package Pinto::Statistics;

# ABSTRACT: Calculates statistics about a Pinto repository

use Moose;

use String::Format;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.030'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has db => (
    is       => 'ro',
    isa      => 'Pinto::Database',
    required => 1,
);

#------------------------------------------------------------------------------
# Methods

sub total_distributions {
    my ($self) = @_;

    return $self->db->select_distributions->count();
}

#------------------------------------------------------------------------------

sub index_distributions {
    my ($self) = @_;

    my $where = { is_latest => 1};
    my $attrs = { select => 'path', join => 'packages', distinct => 1 };

    return $self->db->select_distributions($where, $attrs)->count();
}

#------------------------------------------------------------------------------

sub total_packages {
    my ($self) = @_;

    return $self->db->select_packages->count();
}

#------------------------------------------------------------------------------

sub index_packages {
    my ($self) = @_;

    my $where = {is_latest => 1};

    return $self->db->select_packages( $where )->count();
}

#------------------------------------------------------------------------------

# TODO: Other statistics to consider...
#
# foreign packages (total/indexed)
# local   packages (total/indexed)
# foreign dists    (total/indexed)
# local   dists    (total/indexed)
# avg pkgs per dist
# avg # pkg revisions
# authors
# most prolific author
# N most recently added dist

#------------------------------------------------------------------------------

sub to_formatted_string {
    my ($self, $format) = @_;

    my %fspec = (
        'D' => sub { $self->total_distributions()   },
        'd' => sub { $self->index_distributions()   },
        'P' => sub { $self->total_packages()        },
        'p' => sub { $self->index_packages()        },
    );

    $format ||= $self->default_format();
    return String::Format::stringf($format, %fspec);
}

#------------------------------------------------------------------------------

sub default_format {
    my ($self) = @_;

    return <<'END_FORMAT';
                     Index      Total
               ----------------------
     Packages  %10p  %10P
Distributions  %10d  %10D
END_FORMAT

}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Statistics - Calculates statistics about a Pinto repository

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


