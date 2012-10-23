# ABSTRACT: Report statistics about a Pinto repository

package Pinto::Statistics;

use Moose;
use MooseX::Types::Moose qw(Str);

use String::Format;

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.060'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has stack => (
    is      => 'ro',
    isa     => Str,
);


has db => (
    is       => 'ro',
    isa      => 'Pinto::Database',
    required => 1,
);

#------------------------------------------------------------------------------
# Methods

sub total_distributions {
    my ($self) = @_;

    return $self->db->select_distributions->count;
}

#------------------------------------------------------------------------------

sub stack_distributions {
    my ($self) = @_;

    my $where = { 'stack.name' => $self->stack };
    my $attrs = { select   => 'distribution_path',
                  join     => 'stack',
                  distinct => 1 };

    return $self->db->select_registrations( $where, $attrs )->count;
}

#------------------------------------------------------------------------------

sub total_packages {
    my ($self) = @_;

    return $self->db->select_packages->count;
}

#------------------------------------------------------------------------------

sub stack_packages {
    my ($self) = @_;

    my $where = { 'stack.name' => $self->stack };
    my $attrs = { join => 'stack' };

    return $self->db->select_registrations( $where, $attrs )->count;
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
        'D' => sub { $self->total_distributions   },
        'd' => sub { $self->stack_distributions   },
        'k' => sub { $self->stack                 },
        'P' => sub { $self->total_packages        },
        'p' => sub { $self->stack_packages        },
    );

    $format ||= $self->default_format();
    return String::Format::stringf($format, %fspec);
}

#------------------------------------------------------------------------------

sub default_format {
    my ($self) = @_;

    return <<'END_FORMAT';

STATISTICS FOR THE "%k" STACK
-------------------------------------

                     Stack      Total
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

Pinto::Statistics - Report statistics about a Pinto repository

=head1 VERSION

version 0.060

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


