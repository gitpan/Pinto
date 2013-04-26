# ABSTRACT: Utility class for commit message templates

package Pinto::CommitMessage;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw(Str);
use MooseX::MarkAsMethods (autoclean => 1);

use overload ( q{""} => 'to_string' );

#------------------------------------------------------------------------------

our $VERSION = '0.081'; # VERSION

#------------------------------------------------------------------------------

has title => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has stack => (
    is      => 'ro',
    isa     => 'Pinto::Schema::Result::Stack',
    required => 1,
);


has diff => (
    is       => 'ro',
    isa      => 'Pinto::Difference',
    required => 1,
);

#------------------------------------------------------------------------------

sub to_string {
    my ($self) = @_;

    my $title = $self->title;
    my $stack = $self->stack;
    my $diff  = $self->diff;

    $diff =~ s/^/# /gm;

    return <<"END_MESSAGE";
$title


#-------------------------------------------------------------------------------
# Please edit or amend the message above as you see fit.  The first line of the 
# message will be used as the title.  Any line that starts with a "#" will be 
# ignored.  To abort the commit, delete the entire message above, save the file, 
# and close the editor. 
#
# Changes to be committed to stack $stack:
#
$diff
END_MESSAGE
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

=pod

=for :stopwords Jeffrey Ryan Thalhammer

=head1 NAME

Pinto::CommitMessage - Utility class for commit message templates

=head1 VERSION

version 0.081

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
