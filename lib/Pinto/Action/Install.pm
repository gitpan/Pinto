# ABSTRACT: Install packages from the repository

package Pinto::Action::Install;

use Moose;
use MooseX::Types::Moose qw(Bool HashRef ArrayRef Maybe Str);

use File::Which qw(which);

use Pinto::Types qw(StackName StackDefault);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#------------------------------------------------------------------------------

our $VERSION = '0.059'; # VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Committable );

#------------------------------------------------------------------------------

has cpanm_options => (
    is      => 'ro',
    isa     => HashRef[Maybe[Str]],
    default => sub { {} },
    lazy    => 1,
);


has cpanm_exe => (
    is      => 'ro',
    isa     => Str,
    default => sub { which('cpanm') || throw 'Could not find cpanm in PATH' },
    lazy    => 1,
);


has stack   => (
    is        => 'ro',
    isa       => StackName | StackDefault,
    default   => undef,
);


has targets => (
    isa      => ArrayRef[Str],
    traits   => [ 'Array' ],
    handles  => { targets => 'elements' },
    required => 1,
);


has pull => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

#------------------------------------------------------------------------------

sub BUILD {
    my ($self) = @_;

    my $cpanm_exe = $self->cpanm_exe;

    my $cpanm_version_cmd = "$cpanm_exe --version";
    my $cpanm_version_cmd_output = qx{$cpanm_version_cmd};  ## no critic qw(Backtick)
    throw "Could not learn version of cpanm: $!" if $?;

    my ($cpanm_version) = $cpanm_version_cmd_output =~ m{version ([\d.]+)}
      or throw "Could not parse cpanm version number from $cpanm_version_cmd_output";

    my $min_cpanm_version = '1.5013';
    if ($cpanm_version < $min_cpanm_version) {
      throw "Your cpanm ($cpanm_version) is too old. Must have $min_cpanm_version or newer";
    }

    return $self;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->pull ? $self->repos->open_stack(name => $self->stack)
                            : $self->repos->get_stack(name => $self->stack);

    do { $self->_pull($stack, $_) for $self->targets } if $self->pull;

    if ($self->pull and $self->result->made_changes and not $self->dryrun) {
        my $message = $self->edit_message(stacks => [$stack]);
        $stack->close(message => $message);
        $self->repos->write_index(stack => $stack);
    }

    $self->_install($stack, $self->targets);

    return $self->result;
 }

#------------------------------------------------------------------------------

sub _pull {
    my ($self, $stack, $target) = @_;

    if (-d $target or -f $target) {
        $self->info("Target $target is a file or directory.  Won't pull it");
        return $self;
    }

    my $target_spec = Pinto::SpecFactory->make_spec($target);
    my ($dist, $did_pull) = $self->repos->find_or_pull(target => $target_spec, stack => $stack);

    my $did_register = $dist ? $dist->register(stack => $stack) : undef;
    $did_pull += $self->repos->pull_prerequisites(dist => $dist, stack => $stack);

    $self->result->changed if $did_pull or $did_register;

    return $self;
}

#------------------------------------------------------------------------------

sub _install {
    my ($self, $stack, @targets) = @_;

    # Wire cpanm to our repo
    my $opts = $self->cpanm_options;
    $opts->{'mirror-only'} = '';
    $opts->{mirror} = 'file://' . $self->repos->root->absolute . "/$stack";

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
    0 == system($self->cpanm_exe, @cpanm_opts, @targets)
      or throw "Installation failed.  See the cpanm build log for details";

    return $self;
}

#------------------------------------------------------------------------------

sub message_primer {
    my ($self) = @_;

    my $targets  = join ', ', $self->targets;
    return "Pulled ${targets}.";
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

version 0.059

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
