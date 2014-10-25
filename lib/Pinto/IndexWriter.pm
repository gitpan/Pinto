package Pinto::IndexWriter;

# ABSTRACT: Write records to an 02packages.details.txt file

use Moose;

use PerlIO::gzip;

use Pinto::Exceptions qw(throw_fatal);

#------------------------------------------------------------------------------

our $VERSION = '0.028'; # VERSION

#------------------------------------------------------------------------------
# Attributes

has db => (
    is       => 'ro',
    isa      => 'Pinto::Database',
    required => 1,
);

#------------------------------------------------------------------------------
# Roles

with qw(Pinto::Interface::Loggable);

#------------------------------------------------------------------------------
# Methods

sub write {                                       ## no critic (BuiltinHomonym)
    my ($self, %args) = @_;

    my $file = $args{file};
    $self->note("Writing index at $file");

    open my $fh, '>:gzip', $file or throw_fatal "Cannot open $file: $!";
    $self->_write_header($fh, $file);
    $self->_write_packages($fh);
    close $fh;

    return $self;
}

#------------------------------------------------------------------------------

sub _write_header {
    my ($self, $fh, $filename) = @_;

    my $base    = $filename->basename();
    my $url     = 'file://' . $filename->absolute->as_foreign('Unix');
    my $version = $Pinto::IndexWriter::VERSION || 'UNKNOWN VERSION';

    print {$fh} <<"END_PACKAGE_HEADER";
File:         $base
URL:          $url
Description:  Package names found in directory \$CPAN/authors/id/
Columns:      package name, version, path
Intended-For: Automated fetch routines, namespace documentation.
Written-By:   Pinto::IndexWriter $version
Line-Count:   UNKNOWN
Last-Updated: @{[ scalar localtime() ]}

END_PACKAGE_HEADER

    return $self;
}

#------------------------------------------------------------------------------

sub _write_packages {
    my ($self, $fh) = @_;

    for my $details_record ( $self->_get_index_records() ) {
        my ($name, $version, $path) = @{ $details_record };
        my $width = 38 - length $version;
        $width = length $name if $width < length $name;
        printf {$fh} "%-${width}s %s  %s\n", $name, $version, $path;
    }

    return $self;
}

#------------------------------------------------------------------------------

sub _get_index_records {
    my ($self) = @_;

    # The index is rewritten after almost every action, so we want
    # this to be as fast as possible (especially during an Add or
    # Remove action).  Therefore, we use a cursor to get raw data and
    # skip all the DBIC extras.

    # Yes, slurping all the records at once consumes a lot of memory,
    # but I want them to be sorted the way perl sorts them, not the
    # way sqlite sorts them.  That way, the index file looks more
    # like one produced by PAUSE.  Also, this is about twice as fast
    # as using an iterator to read each record lazily.

    my $where  = { is_latest => 1 };
    my $select = [ qw(name version distribution.path) ];
    my $attrs  = { select => $select, join => 'distribution'};

    my $records = $self->db->select_packages( $where, $attrs );
    my @records =  sort {$a->[0] cmp $b->[0]} $records->cursor()->all();

    return @records;

}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::IndexWriter - Write records to an 02packages.details.txt file

=head1 VERSION

version 0.028

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__





