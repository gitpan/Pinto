# ABSTRACT: Command-line driver for Pinto

package App::Pinto;

use strict;
use warnings;

use Class::Load;
use App::Cmd::Setup -app;
use Pinto::Util qw(is_remote_repo);

#------------------------------------------------------------------------------

our $VERSION = '0.095'; # VERSION

#------------------------------------------------------------------------------

sub global_opt_spec {

    return (
        [ 'root|r=s'           => 'Path to your repository root directory' ],
        [ 'no-color|no-colour' => 'Do not colorize any output' ],
        [ 'password|p=s'       => 'Password for server authentication' ],
        [ 'quiet|q'            => 'Only report fatal errors' ],
        [ 'username|u=s'       => 'Username for server authentication' ],
        [ 'verbose|v+'         => 'More diagnostic output (repeatable)' ],
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

        my $pinto_class = $self->pinto_class_for( $global_options->{root} );
        Class::Load::load_class($pinto_class);

        $pinto_class->new( %{$global_options} );
    };
}

#------------------------------------------------------------------------------

sub pinto_class_for {
    my ( $self, $root ) = @_;
    return is_remote_repo($root) ? 'Pinto::Remote' : 'Pinto';
}

#------------------------------------------------------------------------------

sub _prompt_for_password {
    my ($self) = @_;

    require Encode;
    require IO::Prompt;

    my $repo     = $self->global_options->{root};
    my $prompt   = "Password for repository at $repo: ";
    my $input    = IO::Prompt::prompt( $prompt, -echo => '*', -tty );
    my $password = Encode::decode_utf8($input);

    return $password;
}

#-------------------------------------------------------------------------------

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Jeffrey Ryan Thalhammer BenRifkah Fowler Jakob Voss Karen Etheridge Michael
G. Bergsten-Buret Schwern Oleg Gashev Steffen Schwigon Tommy Stanton
Wolfgang Kinkeldei Yanick Boris Champoux hesco popl Däppen Cory G Watson
David Steinbrunner Glenn

=head1 NAME

App::Pinto - Command-line driver for Pinto

=head1 VERSION

version 0.095

=head1 SYNOPSIS

L<pinto> to create and manage a Pinto repository.

L<pintod> to allow remote access to your Pinto repository.

L<Pinto::Manual> for general information on using Pinto.

L<Stratopan|http://stratopan.com> for hosting your Pinto repository in the cloud.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
