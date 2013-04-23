# ABSTRACT: Command-line driver for Pinto

package App::Pinto;

use strict;
use warnings;

use Class::Load;
use App::Cmd::Setup -app;

#------------------------------------------------------------------------------

our $VERSION = '0.079_04'; # VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {

    return (
        [ 'root|r=s'           => 'Path to your repository root directory'  ],
        [ 'no-color|no-colour' => 'Do not colorize any output'              ],
        [ 'password|p=s'       => 'Password for server authentication'      ],
        [ 'quiet|q'            => 'Only report fatal errors'                ],
        [ 'username|u=s'       => 'Username for server authentication'      ],
        [ 'verbose|v+'         => 'More diagnostic output (repeatable)'     ],
    );
}

#------------------------------------------------------------------------------

sub pinto {
    my ($self) = @_;

    return $self->{pinto} ||= do {
        my $global_options = $self->global_options;

        $global_options->{root} ||= $ENV{PINTO_REPOSITORY_ROOT}
            || $self->usage_error('Must specify a repository root');

        $global_options->{password} = $self->_prompt_for_password
            if defined $global_options->{password} and $global_options->{password} eq '-';

        my $pinto_class = $self->pinto_class_for($global_options->{root});
        Class::Load::load_class($pinto_class);

        $pinto_class->new( %{ $global_options } );
    };
}

#------------------------------------------------------------------------------

sub pinto_class_for {
    my ($self, $root) = @_;
    return $root =~ m{^http://}x ? 'Pinto::Remote' : 'Pinto';
}

#------------------------------------------------------------------------------

sub _prompt_for_password {
   my ($self) = @_;

   require Encode;
   require Term::Prompt;

   my $input    = Term::Prompt::prompt('p', 'Password:', '', '');
   my $password = Encode::decode_utf8($input);
   print "\n"; # Get on a new line

   return $password;
}

#-------------------------------------------------------------------------------


1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

App::Pinto - Command-line driver for Pinto

=head1 VERSION

version 0.079_04

=head1 SYNOPSIS

L<pinto> to create and manage a Pinto repository.

L<pintod> to allow remote access to your Pinto repository.

L<Pinto::Manual> for general information on using Pinto.

L<Stratopan|http://stratopan.com> for hosting your Pinto repository in the cloud.

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