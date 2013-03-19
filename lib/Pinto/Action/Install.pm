# ABSTRACT: Install packages from the repository

package Pinto::Action::Install;

use Moose;
use MooseX::Types::Moose qw(Bool ArrayRef Str);
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::SpecFactory;

#------------------------------------------------------------------------------

our $VERSION = '0.065_03'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

has targets => (
    isa      => ArrayRef[Str],
    traits   => [ 'Array' ],
    handles  => { targets => 'elements' },
    required => 1,
);


has do_pull => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable Pinto::Role::Puller Pinto::Role::Installer);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my @dists;
    if ($self->do_pull) {

        for my $target ($self->targets) {
            next if -d $target or -f $target;

            require Pinto::SpecFactory;
            $target = Pinto::SpecFactory->make_spec($target);
            
            my $dist = $self->pull(target => $target);
            push @dists, $dist ? $dist : ();
        }
    }

    return @dists;
 }

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Action::Install - Install packages from the repository

=head1 VERSION

version 0.065_03

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
