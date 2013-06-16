#!perl

use strict;
use warnings;

use Test::More tests => 1;

use ExtUtils::MakeMaker;
use File::Spec::Functions;
use List::Util qw/max/;

my @modules = qw(
  Apache::Htpasswd
  App::Cmd::Command::help
  App::Cmd::Setup
  Archive::Extract
  Archive::Tar
  Authen::Simple::Passwd
  CPAN::Checksums
  CPAN::DistnameInfo
  CPAN::Meta
  Capture::Tiny
  Carp
  Class::Load
  Cwd
  Cwd::Guard
  DBD::SQLite
  DBIx::Class
  DBIx::Class::Core
  DBIx::Class::ResultSet
  DBIx::Class::Schema
  DateTime
  DateTime::TimeZone
  DateTime::TimeZone::Local::Unix
  DateTime::TimeZone::OffsetOnly
  Devel::StackTrace
  Digest::MD5
  Digest::SHA
  Dist::Metadata
  Encode
  English
  Exporter
  ExtUtils::MakeMaker
  File::Copy
  File::Find
  File::HomeDir
  File::NFSLock
  File::Spec
  File::Spec::Functions
  File::Temp
  File::Which
  FindBin
  Getopt::Long
  HTTP::Body
  HTTP::Date
  HTTP::Request
  HTTP::Request::Common
  HTTP::Response
  IO::File
  IO::Handle
  IO::Interactive
  IO::Pipe
  IO::Prompt
  IO::Select
  IO::String
  IO::Zlib
  JSON
  JSON::PP
  LWP::UserAgent
  List::MoreUtils
  List::Util
  Module::Build
  Module::Build::CleanInstall
  Module::CoreList
  Module::Faker
  Moose
  Moose::Role
  MooseX::Aliases
  MooseX::ClassAttribute
  MooseX::Configuration
  MooseX::MarkAsMethods
  MooseX::NonMoose
  MooseX::SetOnce
  MooseX::StrictConstructor
  MooseX::Types
  MooseX::Types::Moose
  Package::Locator
  Path::Class
  Path::Class::Dir
  Path::Class::File
  Plack::MIME
  Plack::Middleware::Auth::Basic
  Plack::Request
  Plack::Response
  Plack::Runner
  Plack::Test
  Pod::Usage
  Proc::Fork
  Readonly
  Router::Simple
  Scalar::Util
  Starman
  String::Format
  Term::ANSIColor
  Term::EditorEdit
  Test::Exception
  Test::File
  Test::LWP::UserAgent
  Test::More
  Test::Warn
  Throwable::Error
  Try::Tiny
  URI
  UUID::Tiny
  base
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
    delete $prereqs->{develop};
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
