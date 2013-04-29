
use strict;
use warnings;

use Module::Build 0.3601;
use lib qw{inc}; use Pinto::Module::Build;

my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Module::Build::CleanInstall" => "0.05"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601",
    "Module::Build::CleanInstall" => "0.05"
  },
  "dist_abstract" => "Curate a repository of Perl modules",
  "dist_author" => [
    "Jeffrey Ryan Thalhammer <jeff\@stratopan.com>"
  ],
  "dist_name" => "Pinto",
  "dist_version" => "0.082",
  "license" => "perl",
  "module_name" => "Pinto",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "App::Cmd::Setup" => 0,
    "Archive::Extract" => 0,
    "Archive::Tar" => 0,
    "CPAN::Checksums" => 0,
    "CPAN::DistnameInfo" => 0,
    "CPAN::Meta" => 0,
    "Carp" => 0,
    "Class::Load" => 0,
    "Cwd" => 0,
    "Cwd::Guard" => 0,
    "DBD::SQLite" => "1.33",
    "DBIx::Class" => "0.08200",
    "DBIx::Class::Core" => 0,
    "DBIx::Class::ResultSet" => 0,
    "DBIx::Class::Schema" => 0,
    "DateTime" => 0,
    "DateTime::TimeZone" => 0,
    "DateTime::TimeZone::Local::Unix" => 0,
    "DateTime::TimeZone::OffsetOnly" => 0,
    "Devel::StackTrace" => 0,
    "Digest::MD5" => 0,
    "Digest::SHA" => 0,
    "Dist::Metadata" => "0.924",
    "Encode" => 0,
    "English" => 0,
    "Exporter" => 0,
    "File::Copy" => 0,
    "File::Find" => 0,
    "File::HomeDir" => 0,
    "File::NFSLock" => 0,
    "File::Spec" => 0,
    "File::Temp" => 0,
    "File::Which" => 0,
    "Getopt::Long" => 0,
    "HTTP::Date" => 0,
    "HTTP::Request::Common" => 0,
    "HTTP::Server::PSGI" => 0,
    "HTTP::Tiny" => 0,
    "IO::File" => 0,
    "IO::Handle" => 0,
    "IO::Handle::Util" => 0,
    "IO::Interactive" => 0,
    "IO::Pipe" => 0,
    "IO::String" => 0,
    "IO::Zlib" => 0,
    "IPC::Run" => 0,
    "JSON" => 0,
    "JSON::PP" => "2.27103",
    "LWP::UserAgent" => 0,
    "List::MoreUtils" => 0,
    "List::Util" => 0,
    "Module::CoreList" => "2.85",
    "Module::Faker" => "0.014",
    "Module::Faker::Dist" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "MooseX::Aliases" => 0,
    "MooseX::ClassAttribute" => "0.27",
    "MooseX::Configuration" => 0,
    "MooseX::MarkAsMethods" => 0,
    "MooseX::NonMoose" => 0,
    "MooseX::SetOnce" => 0,
    "MooseX::StrictConstructor" => 0,
    "MooseX::Types" => 0,
    "MooseX::Types::Moose" => 0,
    "POSIX" => 0,
    "Package::Locator" => "0.006",
    "Path::Class" => 0,
    "Path::Class::Dir" => 0,
    "Path::Class::File" => 0,
    "Plack::MIME" => 0,
    "Plack::Middleware::Auth::Basic" => 0,
    "Plack::Request" => 0,
    "Plack::Response" => 0,
    "Plack::Runner" => 0,
    "Pod::Usage" => 0,
    "Proc::Fork" => 0,
    "Readonly" => 0,
    "Router::Simple" => 0,
    "Scalar::Util" => 0,
    "Starman" => 0,
    "String::Format" => 0,
    "Term::ANSIColor" => "2.02",
    "Term::EditorEdit" => 0,
    "Term::Prompt" => 0,
    "Test::Builder::Module" => 0,
    "Test::Exception" => 0,
    "Test::TCP" => 0,
    "Throwable::Error" => "0.200005",
    "Try::Tiny" => 0,
    "URI" => 0,
    "UUID::Tiny" => 0,
    "base" => 0,
    "overload" => 0,
    "perl" => "5.008",
    "strict" => 0,
    "utf8" => 0,
    "version" => 0,
    "warnings" => 0
  },
  "script_files" => [
    "bin/pinto",
    "bin/pintod"
  ],
  "test_requires" => {
    "Apache::Htpasswd" => 0,
    "Authen::Simple::Passwd" => 0,
    "ExtUtils::MakeMaker" => 0,
    "File::Spec::Functions" => 0,
    "FindBin" => 0,
    "HTTP::Body" => 0,
    "HTTP::Request" => 0,
    "HTTP::Response" => 0,
    "Plack::Test" => 0,
    "Test::File" => 0,
    "Test::LWP::UserAgent" => 0,
    "Test::More" => 0,
    "Test::Warn" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Pinto::Module::Build->new(%module_build_args);

$build->create_build_script;
