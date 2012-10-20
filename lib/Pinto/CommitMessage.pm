# ABSTRACT: Utility class for constructing commit messages

package Pinto::CommitMessage;

use Moose;
use MooseX::Types::Moose qw(ArrayRef Str);

use Term::EditorEdit;
use Text::Wrap qw(wrap);

use overload ( q{""} => 'to_string' );

#------------------------------------------------------------------------------

our $VERSION = '0.059'; # VERSION

#------------------------------------------------------------------------------

has stacks => (
    traits  => [ qw(Array) ],
    isa     => ArrayRef[ 'Pinto::Schema::Result::Stack' ],
    handles => {stacks => 'elements'},
    default => sub { [] },
);


has primer => (
    is      => 'ro',
    isa     => Str,
    default => '',
);


has details => (
    is      => 'ro',
    isa     => Str,
    builder => '_build_details',
    lazy    => 1,
);

#------------------------------------------------------------------------------

sub _build_details {
    my ($self) = @_;

    my @stacks = $self->stacks;

    return 'No details available' if not @stacks;

    my $details = '';
    for my $stack ( @stacks ) {
        $details .= "STACK: $stack\n" if @stacks > 1;
        $details .= $stack->head_revision->change_details || 'No details available';
        $details.= "\n\n";
    }

    return $details;
}

#------------------------------------------------------------------------------

sub edit {
    my ($self) = @_;

    my $message = Term::EditorEdit->edit(document => $self->to_string);
    $message =~ s/( \n+ -{60,} \n .*)//smx;  # Strip details

    return $message;
}

#------------------------------------------------------------------------------

sub to_string {
    my ($self) = @_;

    local $Text::Wrap::columns = 80;
    my $primer  = wrap(undef, undef, $self->primer);
    my $details = $self->details;

    return <<END_MESSAGE;
$primer

------------------------------------------------------------------------------
Please replace or edit the message above to describe the change.  It is more
helpful to explain *why* the change happened, rather than *what* happened.
Details of the change follow:

$details
END_MESSAGE
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::CommitMessage - Utility class for constructing commit messages

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
