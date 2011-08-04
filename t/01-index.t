#!perl

use strict;
use warnings;
use Test::More (tests => 10);

use Pinto::Index;
use Pinto::Package;


#-----------------------------------------------------------------------------

my $index = Pinto::Index->new();

#-----------------------------------------------------------------------------
# Adding...

$index->add( mkpkg('Foo') );
is($index->package_count(), 1,
   'Added one package');

$index->add( mkpkg('Foo', undef, '2.0') );
is($index->package_count(), 1,
   'Added same package again');
is($index->find(package=>'Foo')->version(), '2.0',
   'Adding same package again overrides original');

#-----------------------------------------------------------------------------
# Removing...

$index->clear();
$index->add( mkpkg(['Bar', 'Baz']) );
is($index->package_count(), 2,
   'Added two packages at the same time');

$index->remove( 'Bar' );
is($index->package_count(), 0,
   'Removed a package');
is($index->find(package=>'Bar'), undef,
   'Package Bar is removed');
is($index->find(package=>'Baz'), undef,
   'Package Baz is removed');

#-----------------------------------------------------------------------------
# Merging...

$index->clear();
$index->add( mkpkg(['Eenie', 'Meenie']) );
$index->merge( mkpkg(['Meenie', 'Moe'], undef, '2.0') );

is($index->find(package=>'Meenie')->version(), '2.0',
    'Incument package replaced with mine');

is($index->find(package=>'Eenie'), undef,
    'Extra incumbent packages are gone');

is($index->find(package=>'Moe')->version(), '2.0',
    'New package is in place');


#-----------------------------------------------------------------------------

sub mkpkg {
    my ($pkg_names, $file, $version, $author) = @_;

    $version ||= '1.0';
    $pkg_names = [ $pkg_names ] if ref $pkg_names ne 'ARRAY';
    $file    ||= $pkg_names->[0] . "-$version.tar.gz";
    $author  ||= 'CHAUCER';

    return map { Pinto::Package->new( name => $_,
                                      file => $file,
                                      version => $version,
                                      author  => $author ) } @{$pkg_names};
}
