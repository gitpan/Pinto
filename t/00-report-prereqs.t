#!perl

use strict;
use warnings;

use Test::More;

use ExtUtils::MakeMaker;
use File::Spec::Functions;
use List::Util qw/max/;

if ( $ENV{AUTOMATED_TESTING} ) {
  plan tests => 1;
}
else {
  plan skip_all => '$ENV{AUTOMATED_TESTING} not set';
}

my @modules = qw(
  CPAN::Checksums
  CPAN::DistnameInfo
  Carp
  Class::Load
  Cwd::Guard
  DBD::SQLite
  DBIx::Class
  DBIx::Class::Core
  DBIx::Class::Schema
  DateTime
  Digest::SHA
  Dist::Metadata
  Exporter
  ExtUtils::MakeMaker
  File::Basename
  File::Copy
  File::Find
  File::NFSLock
  File::Spec::Functions
  File::Temp
  File::Which
  HTTP::Date
  IO::String
  JSON
  LWP::UserAgent
  List::Util
  Log::Dispatch
  Log::Dispatch::File
  Log::Dispatch::Handle
  Module::Build
  Module::CoreList
  Module::Faker::Dist
  Moose
  Moose::Role
  MooseX::Aliases
  MooseX::Configuration
  MooseX::MarkAsMethods
  MooseX::NonMoose
  MooseX::Types::Log::Dispatch
  MooseX::Types::Moose
  Package::Locator
  Path::Class
  PerlIO::gzip
  Pinto::Constants
  Pinto::DistributionSpec
  Pinto::Exception
  Pinto::Globals
  Pinto::PackageSpec
  Pinto::Role::PauseConfig
  Pinto::Types
  Pinto::Util
  Readonly
  SQL::Translator
  Scalar::Util
  String::Format
  Term::EditorEdit
  Test::Builder::Module
  Test::Exception
  Test::File
  Test::Log::Dispatch
  Test::More
  Text::Wrap
  Try::Tiny
  URI
  autodie
  base
  namespace::autoclean
  overload
  perl
  strict
  utf8
  version
  warnings
);

# replace modules with dynamic results from MYMETA.json if we can
# (hide CPAN::Meta from prereq scanner)
my $cpan_meta = "CPAN::Meta";
if ( -f "MYMETA.json" && eval "require $cpan_meta" ) { ## no critic
  if ( my $meta = eval { CPAN::Meta->load_file("MYMETA.json") } ) {
    my $prereqs = $meta->prereqs;
    my %uniq = map {$_ => 1} map { keys %$_ } map { values %$_ } values %$prereqs;
    $uniq{$_} = 1 for @modules; # don't lose any static ones
    @modules = sort keys %uniq;
  }
}

my @reports = [qw/Version Module/];

for my $mod ( @modules ) {
  next if $mod eq 'perl';
  my $file = $mod;
  $file =~ s{::}{/}g;
  $file .= ".pm";
  my ($prefix) = grep { -e catfile($_, $file) } @INC;
  if ( $prefix ) {
    my $ver = MM->parse_version( catfile($prefix, $file) );
    $ver = "undef" unless defined $ver; # Newer MM should do this anyway
    push @reports, [$ver, $mod];
  }
  else {
    push @reports, ["missing", $mod];
  }
}
    
if ( @reports ) {
  my $vl = max map { length $_->[0] } @reports;
  my $ml = max map { length $_->[1] } @reports;
  splice @reports, 1, 0, ["-" x $vl, "-" x $ml];
  diag "Prerequisite Report:\n", map {sprintf("  %*s %*s\n",$vl,$_->[0],-$ml,$_->[1])} @reports;
}

pass;

# vim: ts=2 sts=2 sw=2 et:
