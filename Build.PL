
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::HomeDir' => '0',
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'MooseX::NonMoose' => '0',
    'Test::Builder::Module' => '0',
    'Test::Exception' => '0',
    'Test::File' => '0',
    'Test::More' => '0'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Perl distribution repository manager',
  'dist_author' => [
    'Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>'
  ],
  'dist_name' => 'Pinto',
  'dist_version' => '0.023',
  'license' => 'perl',
  'module_name' => 'Pinto',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'App::Cmd::Setup' => '0',
    'CPAN::DistnameInfo' => '0',
    'Carp' => '0',
    'Class::Load' => '0',
    'Date::Format' => '0',
    'Dist::Metadata' => '0.920',
    'English' => '0',
    'Exception::Class' => '0',
    'Exporter' => '0',
    'File::Compare' => '0',
    'File::Copy' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'IO::Interactive' => '0',
    'IPC::Run' => '0',
    'LWP::UserAgent' => '0',
    'List::MoreUtils' => '0',
    'LockFile::Simple' => '0',
    'Moose' => '0',
    'Moose::Autobox' => '0',
    'Moose::Role' => '0',
    'MooseX::Configuration' => '0',
    'MooseX::Types::Moose' => '0',
    'Path::Class' => '0',
    'PerlIO::gzip' => '0',
    'Pinto::Constants' => '0',
    'Pinto::Types' => '0.017',
    'Pod::Usage' => '0',
    'Readonly' => '0',
    'Term::ANSIColor' => '2.02',
    'Try::Tiny' => '0',
    'URI' => '0',
    'autodie' => '0',
    'namespace::autoclean' => '0',
    'overload' => '0',
    'perl' => '5.008'
  },
  'script_files' => [
    'bin/pinto-admin'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
