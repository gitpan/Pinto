# ABSTRACT: Something pulls packages to a stack

package Pinto::Role::Puller;

use Moose::Role;
use MooseX::Types::Moose qw(Bool);
use MooseX::MarkAsMethods (autoclean => 1);

use Pinto::Util qw(throw);

#-----------------------------------------------------------------------------

our $VERSION = '0.080'; # VERSION

#-----------------------------------------------------------------------------

with qw( Pinto::Role::Plated );

#-----------------------------------------------------------------------------

has no_recurse => (
	is          => 'ro',
	isa         => Bool,
	default     => 0,
);


has pin => (
  is          => 'ro',
  isa         => Bool,
  default     => 0,
);

#-----------------------------------------------------------------------------

# We should require a stack() attribute, but I can't get it to work 
# when composing with the Committable role which provides it.
# requires qw(stack);

#-----------------------------------------------------------------------------

sub pull {
	my ($self, %args) = @_;

	my $target = $args{target};
	my $stack  = $self->stack;
  my $dist;

  if ($target->isa('Pinto::Schema::Result::Distribution')) {
    $dist = $target;
  }
  elsif ($target->isa('Pinto::DistributionSpec')) {
    $dist = $self->find(target => $target);
  }
  elsif ($target->isa('Pinto::PackageSpec')) {

    my $tpv = $stack->target_perl_version;
    if ($target->is_core(in => $tpv)) {
      $self->warning("Skipping $target: included in perl $tpv core");
      return;
    }

    $dist = $self->find(target => $target);
  }
  else {
    throw "Illeagal arguments";
  }

  $dist->register(stack => $stack, pin => $self->pin);
  $self->recurse(start => $dist) unless $self->no_recurse;

  return $dist;
}

#-----------------------------------------------------------------------------

sub find {
  my ($self, %args) = @_;

  my $target = $args{target};
  my $stack  = $self->stack;

  my $dist;
  my $msg;

  if    ($dist = $stack->get_distribution(spec => $target) ) {
    $msg = "Found $target on stack $stack in $dist";
  }
  elsif ($dist = $stack->repo->get_distribution(spec => $target) ) {
    $msg = "Found $target in $dist";
  }
  elsif ($dist = $stack->repo->ups_distribution(spec => $target) ) {
    $msg = "Found $target in " . $dist->source;
  }

  $self->chrome->show_progress;
  $self->info($msg) if defined $msg;
  
  return $dist;
}

#-----------------------------------------------------------------------------

sub recurse {
  my ($self, %args) = @_;

  my $dist  = $args{start};
  my $stack = $self->stack;

  my %latest;
  my $cb = sub {
    my ($prereq) = @_;

    my $pkg_name = $prereq->name;
    my $pkg_vers = $prereq->version;

    # version sees undef and 0 as equal, so must also check definedness 
    # when deciding if we've seen this version (or newer) of the packge
    return if defined($latest{$pkg_name}) && $pkg_vers <= $latest{$pkg_name};

    # I think the only time that we won't see a $dist here is when
    # the prereq resolves to a perl (i.e. its a core-only module).
    return if not my $dist = $self->find(target => $prereq);

    $dist->register(stack => $stack);
    $latest{$pkg_name} = $pkg_vers;

    return $dist;
  };

  require Pinto::PrerequisiteWalker;

  my $tpv    = $stack->target_perl_version;
  my $filter = sub { $_[0]->is_perl || $_[0]->is_core(in => $tpv) };
  my $walker = Pinto::PrerequisiteWalker->new(start => $dist, callback => $cb, filter => $filter);
  
  $self->notice("Descending into prerequisites for $dist");

  while ($walker->next){ }; # We just want the side effects

  return $self;
}

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::Role::Puller - Something pulls packages to a stack

=head1 VERSION

version 0.080

=head1 CONTRIBUTORS

=over 4

=item *

Cory G Watson <gphat@onemogin.com>

=item *

Jakob Voss <jakob@nichtich.de>

=item *

Jeff <jeff@callahan.local>

=item *

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=item *

Jeffrey Thalhammer <jeff@imaginative-software.com>

=item *

Karen Etheridge <ether@cpan.org>

=item *

Michael G. Schwern <schwern@pobox.com>

=item *

Steffen Schwigon <ss5@renormalist.net>

=item *

Wolfgang Kinkeldei <wolfgang@kinkeldei.de>

=item *

Yanick Champoux <yanick@babyl.dyndns.org>

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
