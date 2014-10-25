# ABSTRACT: Interface for terminal-based interaction

package Pinto::Chrome::Term;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Bool ArrayRef);
use MooseX::MarkAsMethods (autoclean => 1);

use Term::ANSIColor ();
use Term::EditorEdit;

use Pinto::Types qw(Io);
use Pinto::Util qw(user_colors is_interactive itis throw);

#-----------------------------------------------------------------------------

our $VERSION = '0.066'; # VERSION

#-----------------------------------------------------------------------------

extends qw( Pinto::Chrome );

#-----------------------------------------------------------------------------

has no_color => (
    is       => 'ro',
    isa      => Bool,
    default  => sub { return !!$ENV{PINTO_NO_COLOR} or 0 },
);


has colors => (
    is        => 'ro',
    isa       => ArrayRef,
    default   => sub { return user_colors },
    lazy      => 1,
);


has stdout => (
    is      => 'ro',
    isa     => Io,
    builder => '_build_stdout',
    coerce  => 1,
    lazy    => 1,
);


has stderr => (
    is      => 'ro',
    isa     => Io,
    default => sub { [fileno(*STDERR), '>'] },
    coerce  => 1,
    lazy    => 1,
);


#-----------------------------------------------------------------------------

sub BUILD {
    my ($self) = @_;

    my @colors = @{ $self->colors };

    throw "Must specify exactly three colors" if @colors != 3;

    Term::ANSIColor::colorvalid($_) || throw "Color $_ is not valid" for @colors;

    return $self;
};

#------------------------------------------------------------------------------

sub _build_stdout {
    my ($self) = @_;

    my $stdout = [fileno(*STDOUT), '>'];
    my $pager = $ENV{PINTO_PAGER} || $ENV{PAGER};

    return $stdout if not is_interactive;
    return $stdout if not $pager;

    open my $pager_fh, q<|->, $pager
        or throw "Failed to open pipe to pager $pager: $!";

    return bless $pager_fh, 'IO::Handle'; # HACK!
}

#------------------------------------------------------------------------------

sub show { 
    my ($self, $msg, $opts) = @_;

    $opts ||= {};

    $msg = $self->colorize($msg, $opts->{color});

    $msg .= "\n" unless $opts->{no_newline};

    print { $self->stdout } $msg or croak $!;

    return $self
}

#-----------------------------------------------------------------------------

sub diag {
    my ($self, $msg, $opts) = @_;

    $opts ||= {};

    $msg = $msg->() if ref $msg eq 'CODE';

    if ( itis($msg, 'Pinto::Exception') ) {
        # Show full stack trace if we are debugging
        $msg = $ENV{PINTO_DEBUG} ? $msg->as_string : $msg->message;
    }

    chomp $msg;

    $msg = $self->colorize($msg, $opts->{color});

    $msg .= "\n" unless $opts->{no_newline};

    print { $self->stderr } $msg or croak $!;
}

#-----------------------------------------------------------------------------

sub show_progress {
    my ($self) = @_;

    return if not $self->should_render_progress;

    $self->stderr->autoflush; # Make sure pipes are hot

    print {$self->stderr} '.' or croak $!;
}

#-----------------------------------------------------------------------------

sub progress_done {
    my ($self) = @_;

    return unless $self->should_render_progress;

    print {$self->stderr} "\n" or croak $!;
}

#-----------------------------------------------------------------------------

sub edit {
    my ($self, $document) = @_;

    local $ENV{VISUAL} = $ENV{PINTO_EDITOR} if $ENV{PINTO_EDITOR};

    return Term::EditorEdit->edit(document => $document);
}

#-----------------------------------------------------------------------------

sub colorize {
    my ($self, $string, $color_number) = @_;

    return ''      if not $string;
    return $string if not defined $color_number;
    return $string if $self->no_color;

    my $color = $self->get_color($color_number);

    return $color . $string . Term::ANSIColor::color('reset');
}

#-----------------------------------------------------------------------------

sub get_color {
    my ($self, $color_number) = @_;

    return '' if not defined $color_number;

    my $color = $self->colors->[$color_number];

    throw "Invalid color number: $color_number" if not defined $color;

    return Term::ANSIColor::color($color);
}

#-----------------------------------------------------------------------------

my %color_map = (warning => 1, error => 2);
while ( my ($level, $color) = each %color_map)  {
    around $level => sub {
        my ($orig, $self, $msg, $opts) = @_;
        $opts ||= {}; $opts->{color} = $color;
        return $self->$orig($msg, $opts); 
    }; 
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-----------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Chrome::Term - Interface for terminal-based interaction

=head1 VERSION

version 0.066

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
