
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Data::Dumper" => 0,
    "File::Find" => 0,
    "File::HomeDir" => 0,
    "File::Temp" => 0,
    "FindBin" => 0,
    "Module::Build" => "0.3601",
    "Test::Exception" => 0,
    "Test::More" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Curate your own CPAN-like repository",
  "dist_author" => [
    "Jeffrey Ryan Thalhammer <jeff\@imaginative-software.com>"
  ],
  "dist_name" => "Pinto",
  "dist_version" => "0.032",
  "license" => "perl",
  "module_name" => "Pinto",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "App::Cmd::Setup" => 0,
    "CPAN::Checksums" => 0,
    "CPAN::DistnameInfo" => 0,
    "Carp" => 0,
    "Class::Load" => 0,
    "DBD::SQLite" => "1.33",
    "DBIx::Class::Core" => 0,
    "DBIx::Class::Schema" => 0,
    "DateTime" => 0,
    "Dist::Metadata" => "0.922",
    "Dist::Requires" => "0.004",
    "Exception::Class" => 0,
    "Exporter" => 0,
    "Git::Repository" => 0,
    "IO::Interactive" => 0,
    "IO::String" => 0,
    "IPC::Run" => 0,
    "LWP::UserAgent" => 0,
    "List::MoreUtils" => 0,
    "LockFile::Simple" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "MooseX::Configuration" => 0,
    "MooseX::NonMoose" => 0,
    "MooseX::Types::Moose" => 0,
    "Package::Locator" => "0.004",
    "Path::Class" => 0,
    "PerlIO::gzip" => 0,
    "Pinto::Types" => "0.020",
    "Pod::Usage" => 0,
    "Readonly" => 0,
    "SQL::Translator" => "0.11009",
    "String::Format" => 0,
    "Term::ANSIColor" => "2.02",
    "Test::Builder::Module" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "autodie" => 0,
    "base" => 0,
    "namespace::autoclean" => 0,
    "overload" => 0,
    "perl" => "5.008",
    "strict" => 0,
    "utf8" => 0,
    "version" => 0,
    "warnings" => 0
  },
  "script_files" => [
    "bin/pinto-admin"
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
