#!perl

use strict;
use warnings;

# This test was generated by Dist::Zilla::Plugin::Test::ReportPrereqs 0.011

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
  CPAN::Meta::Requirements
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
  HTTP::Server::PSGI
  IO::File
  IO::Handle
  IO::Interactive
  IO::Pipe
  IO::Prompt
  IO::Select
  IO::String
  IO::Zlib
  IPC::Open3
  JSON
  JSON::PP
  LWP::UserAgent
  List::MoreUtils
  List::Util
  Module::Build
  Module::Build::CleanInstall
  Module::CoreList
  Module::Faker::Dist
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
  Plack
  Plack::MIME
  Plack::Middleware::Auth::Basic
  Plack::Request
  Plack::Response
  Plack::Runner
  Plack::Test
  Pod::Usage
  Proc::Fork
  Proc::Terminator
  Readonly
  Router::Simple
  Scalar::Util
  Starman
  String::Format
  Term::ANSIColor
  Term::EditorEdit
  Test::Builder::Module
  Test::Exception
  Test::File
  Test::LWP::UserAgent
  Test::More
  Test::TCP
  Test::Warn
  Throwable::Error
  Try::Tiny
  URI
  URI::Escape
  URI::file
  UUID::Tiny
  base
  lib
  overload
  perl
  strict
  utf8
  version
  warnings
);

my %exclude = map {; $_ => 1 } qw(

);

my ($source) = grep { -f $_ } qw/MYMETA.json MYMETA.yml META.json/;
$source = "META.yml" unless defined $source;

# replace modules with dynamic results from MYMETA.json if we can
# (hide CPAN::Meta from prereq scanner)
my $cpan_meta = "CPAN::Meta";
my $cpan_meta_req = "CPAN::Meta::Requirements";
my $all_requires;
if ( -f $source && eval "require $cpan_meta" ) { ## no critic
  if ( my $meta = eval { CPAN::Meta->load_file($source) } ) {

    # Get ALL modules mentioned in META (any phase/type)
    my $prereqs = $meta->prereqs;
    delete $prereqs->{develop} if not $ENV{AUTHOR_TESTING};
    my %uniq = map {$_ => 1} map { keys %$_ } map { values %$_ } values %$prereqs;
    $uniq{$_} = 1 for @modules; # don't lose any static ones
    @modules = sort grep { ! $exclude{$_} } keys %uniq;

    # If verifying, merge 'requires' only for major phases
    if ( 1 ) {
      $prereqs = $meta->effective_prereqs; # get the object, not the hash
      if (eval "require $cpan_meta_req; 1") { ## no critic
        $all_requires = $cpan_meta_req->new;
        for my $phase ( qw/configure build test runtime develop/ ) {
          $all_requires->add_requirements(
            $prereqs->requirements_for($phase, 'requires')
          );
        }
      }
    }
  }
}

my @reports = [qw/Version Module/];
my @dep_errors;
my $req_hash = defined($all_requires) ? $all_requires->as_string_hash : {};

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

    if ( 1 && $all_requires ) {
      my $req = $req_hash->{$mod};
      if ( defined $req && length $req ) {
        if ( ! defined eval { version->parse($ver) } ) {
          push @dep_errors, "$mod version '$ver' cannot be parsed (version '$req' required)";
        }
        elsif ( ! $all_requires->accepts_module( $mod => $ver ) ) {
          push @dep_errors, "$mod version '$ver' is not in required range '$req'";
        }
      }
    }

  }
  else {
    push @reports, ["missing", $mod];

    if ( 1 && $all_requires ) {
      my $req = $req_hash->{$mod};
      if ( defined $req && length $req ) {
        push @dep_errors, "$mod is not installed (version '$req' required)";
      }
    }
  }
}

if ( @reports ) {
  my $vl = max map { length $_->[0] } @reports;
  my $ml = max map { length $_->[1] } @reports;
  splice @reports, 1, 0, ["-" x $vl, "-" x $ml];
  diag "\nVersions for all modules listed in $source (including optional ones):\n",
    map {sprintf("  %*s %*s\n",$vl,$_->[0],-$ml,$_->[1])} @reports;
}

if ( @dep_errors ) {
  diag join("\n",
    "\n*** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ***\n",
    "The following REQUIRED prerequisites were not satisfied:\n",
    @dep_errors,
    "\n"
  );
}

pass;

# vim: ts=2 sts=2 sw=2 et:
