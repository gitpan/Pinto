
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "Log::Dispatch::Handle" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Curate a repository of Perl modules",
  "dist_author" => [
    "Jeffrey Ryan Thalhammer <jeff\@imaginative-software.com>"
  ],
  "dist_name" => "Pinto",
  "dist_version" => "0.040_001",
  "license" => "perl",
  "module_name" => "Pinto",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "App::Cmd::Setup" => 0,
    "App::Cmd::Subdispatch" => 0,
    "CPAN::Checksums" => 0,
    "CPAN::DistnameInfo" => 0,
    "Carp" => 0,
    "Class::Load" => 0,
    "DBD::SQLite" => "1.33",
    "DBIx::Class::Core" => 0,
    "DBIx::Class::Schema" => 0,
    "DateTime" => 0,
    "Digest::MD5" => 0,
    "Digest::SHA" => 0,
    "Dist::Metadata" => "0.922",
    "Dist::Requires" => "0.005",
    "Exporter" => 0,
    "File::Temp" => 0,
    "IO::String" => 0,
    "LWP::UserAgent" => 0,
    "List::Util" => 0,
    "LockFile::Simple" => 0,
    "Log::Dispatch" => 0,
    "Log::Dispatch::File" => 0,
    "Log::Dispatch::Screen" => 0,
    "Log::Dispatch::Screen::Color" => 0,
    "Module::Faker::Dist" => 0,
    "Moose" => 0,
    "Moose::Exporter" => 0,
    "Moose::Role" => 0,
    "MooseX::Aliases" => 0,
    "MooseX::Configuration" => 0,
    "MooseX::MarkAsMethods" => 0,
    "MooseX::NonMoose" => 0,
    "MooseX::Types::Log::Dispatch" => 0,
    "MooseX::Types::Moose" => 0,
    "Package::Locator" => "0.004",
    "Path::Class" => 0,
    "PerlIO::gzip" => 0,
    "Pinto::Common" => "0.040_001",
    "Pinto::Constants" => 0,
    "Pinto::DistributionSpec" => 0,
    "Pinto::PackageSpec" => 0,
    "Pinto::Role::Interface::Action::Add" => 0,
    "Pinto::Role::Interface::Action::List" => 0,
    "Pinto::Role::Interface::Action::Nop" => 0,
    "Pinto::Role::Interface::Action::Pin" => 0,
    "Pinto::Role::Interface::Action::Pull" => 0,
    "Pinto::Role::Interface::Action::Stack::Copy" => 0,
    "Pinto::Role::Interface::Action::Stack::Create" => 0,
    "Pinto::Role::Interface::Action::Stack::Edit" => 0,
    "Pinto::Role::Interface::Action::Stack::List" => 0,
    "Pinto::Role::Interface::Action::Stack::Props" => 0,
    "Pinto::Role::Interface::Action::Statistics" => 0,
    "Pinto::Role::Interface::Action::Unpin" => 0,
    "Pinto::Role::Interface::Action::Verify" => 0,
    "Pinto::Types" => 0,
    "Pod::Usage" => 0,
    "Readonly" => 0,
    "SQL::Translator" => "0.11009",
    "Scalar::Util" => 0,
    "String::Format" => 0,
    "Test::Builder::Module" => 0,
    "Test::Exception" => 0,
    "Test::Log::Dispatch" => 0,
    "Throwable::Error" => 0,
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
