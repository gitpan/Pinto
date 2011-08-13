package Pinto::Server;

# ABSTRACT: Web interface to a Pinto repository

use Moose;

use Pinto;

use Path::Class qw(dir);
use File::Temp  qw(tempdir);

use base 'CGI::Application';

use CGI::Application::Plugin::AutoRunmode;

#-----------------------------------------------------------------------------

our $VERSION = '0.009'; # VERSION

#-----------------------------------------------------------------------------

has 'pinto'  => (
    is         => 'ro',
    isa        => 'Pinto',
    lazy_build => 1,
);

#-----------------------------------------------------------------------------

sub _build_pinto {
    my ($self) = @_;

    my $config = Pinto::Config->new();
    my $logger = Pinto::Logger->new();
    my $pinto  = Pinto->new(config => $config, logger => $logger);

    return $pinto;
}

#-----------------------------------------------------------------------------

sub add :Runmode {
    my $self = shift;

    my $query     = $self->query();
    my $author    = $query->param('author');
    my $file      = $query->param('file');

    if (not $file) {
        $self->header_add(-status => '400 No distribution file supplied');
        return;
    }

    if (not $author) {
        $self->header_add(-status => '400 No author supplied');
        return;
    }


    my $tmpdir = dir( tempdir(CLEANUP => 1) );
    my $tmpfile = $tmpdir->file($file);
    my $fh = $tmpfile->openw();

    while ( read($file, my $buffer, 1024) ) { print { $fh } $buffer }
    $fh->close();

    my $ok = eval { $self->pinto->add( file   => $tmpfile,
                                       author => $author ); 1 };

    my $status = $ok ? '202 Module added' : "500 Error: $@";
    $self->header_add(-status => $status);

    return;
}

#----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Server - Web interface to a Pinto repository

=head1 VERSION

version 0.009

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
