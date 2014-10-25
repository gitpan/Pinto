# ABSTRACT: Record events in the repository log file (and elsewhere).

package Pinto::Logger;

use Moose;
use MooseX::Types::Moose qw(Str);

use DateTime;
use Log::Dispatch;
use Log::Dispatch::File;

use Pinto::Util qw(itis);
use Pinto::Types qw(Dir File);
use Pinto::Exception qw(throw);

use namespace::autoclean;

#-----------------------------------------------------------------------------

our $VERSION = '0.059'; # VERSION

#-----------------------------------------------------------------------------
# Roles

with qw(Pinto::Role::Configurable);

#-----------------------------------------------------------------------------
# Attributes

has log_level => (
    is      => 'ro',
    isa     => Str,
    default => sub { $_[0]->config->log_level },
);


has log_file => (
    is      => 'ro',
    isa     => File,
    default => sub { $_[0]->config->log_file },
    coerce  => 1,
);


has log_handler => (
    is       => 'ro',
    isa      => 'Log::Dispatch',
    builder  => '_build_log_handler',
    handles  => [qw(debug info notice warning error)], # fatal is handled below
    lazy     => 1,
);

#-----------------------------------------------------------------------------

sub _build_log_handler {
    my ($self) = @_;

    my $log_dir = $self->log_file->dir;
    $log_dir->mkpath if not -e $log_dir;

    my $log_filename = $self->log_file->stringify;

    my $cb = sub { my %args  = @_;
                   my $msg   = $args{message};
                   my $level = uc $args{level};
                   my $now   = DateTime->now->iso8601;
                   return "$now $level: $msg" };


    my $out = Log::Dispatch::File->new( min_level   => $self->log_level,
                                        filename    => $log_filename,
                                        mode        => 'append',
                                        permissions => 0644,
                                        callbacks   => $cb,
                                        newline     => 1 );

    my $handler = Log::Dispatch->new();
    $handler->add($out);

    return $handler;
}

#-----------------------------------------------------------------------------


sub add_output {
    my ($self, $output) = @_;

    my $base_class = 'Log::Dispatch::Output';
    itis($output, $base_class) or throw "Argument is not a $base_class";

    $self->log_handler->add($output);

    return $self;
}

#-----------------------------------------------------------------------------

sub fatal {
    my ($self, $message) = @_;

    # The $message could be a Pinto::Exception object, or it might just be
    # a string.  If it is an object and the logger is set at the debug level
    # then log the entire stack trace.  But if not, then just log the main
    # message (or the $message itself, if it is not a Pinto::Exception)

    if (itis($message, 'Pinto::Exception')) {
        my $is_debug_log = $self->log_handler->is_debug;
        $message = $is_debug_log ? $message->as_string : $message->message;
    }

    chomp $message;
    $self->log_handler->log_and_croak(level => 'critical', message => $message);
}


#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Logger - Record events in the repository log file (and elsewhere).

=head1 VERSION

version 0.059

=head1 METHODS

=head2 add_output( $obj )

Adds the object to the output destinations that this logger writes to.
The object must be an instance of a L<Log::Dispatch::Output> subclass,
such as L<Log::Dispatch::Screen> or L<Log::Dispatch::Handle>.

=head1 LOGGING METHODS

The following methods are available for writing to the logs at various
levels (listed in order of increasing priority).  Each method takes a
single message as an argument.

=over

=item debug

=item info

=item notice

=item warning

=item error

=item fatal

Note that C<fatal> causes the application to throw an exception.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

