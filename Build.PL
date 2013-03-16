
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec::Functions" => 0,
    "Log::Dispatch::Handle" => 0,
    "Module::Build" => "0.3601",
    "Test::File" => 0,
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
  "dist_version" => "0.065_02",
  "license" => "perl",
  "module_name" => "Pinto",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "CPAN::Checksums" => 0,
    "CPAN::DistnameInfo" => 0,
    "Carp" => 0,
    "Class::Load" => 0,
    "DBD::SQLite" => "1.33",
    "DBIx::Class" => "0.08200",
    "DBIx::Class::Core" => 0,
    "DBIx::Class::ResultSet" => 0,
    "DBIx::Class::Schema" => 0,
    "DateTime" => 0,
    "DateTime::TimeZone" => 0,
    "DateTime::TimeZone::OffsetOnly" => 0,
    "Digest::SHA" => 0,
    "Dist::Metadata" => "0.924",
    "English" => 0,
    "Exporter" => 0,
    "File::Copy" => 0,
    "File::Find" => 0,
    "File::NFSLock" => 0,
    "File::ShareDir" => 0,
    "File::Temp" => 0,
    "File::Which" => 0,
    "HTTP::Date" => 0,
    "IO::Handle" => 0,
    "IO::String" => 0,
    "IO::Zlib" => 0,
    "JSON" => 0,
    "JSON::PP" => "2.27103",
    "LWP::UserAgent" => 0,
    "List::Util" => 0,
    "Log::Dispatch" => "2.31",
    "Log::Dispatch::File" => 0,
    "Module::CoreList" => 0,
    "Module::Faker::Dist" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "MooseX::Aliases" => 0,
    "MooseX::Configuration" => 0,
    "MooseX::MarkAsMethods" => 0,
    "MooseX::NonMoose" => 0,
    "MooseX::SetOnce" => 0,
    "MooseX::Types::Moose" => 0,
    "Package::Locator" => "0.006",
    "Path::Class" => 0,
    "Pinto::Constants" => "0.065_01",
    "Pinto::DistributionSpec" => 0,
    "Pinto::Exception" => 0,
    "Pinto::Globals" => 0,
    "Pinto::PackageSpec" => 0,
    "Pinto::Role::PauseConfig" => 0,
    "Pinto::SpecFactory" => 0,
    "Pinto::Types" => "0.065_01",
    "Pinto::Util" => "0.065_01",
    "Readonly" => 0,
    "String::Format" => 0,
    "Term::ANSIColor" => 0,
    "Term::EditorEdit" => 0,
    "Test::Builder::Module" => 0,
    "Test::Exception" => 0,
    "Test::Log::Dispatch" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "base" => 0,
    "overload" => 0,
    "perl" => "5.008",
    "strict" => 0,
    "utf8" => 0,
    "version" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "share_dir" => {
    "dist" => "share"
  }
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
