
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Test::Exception' => '0',
    'Test::More' => '0'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Perl archive repository manager',
  'dist_author' => [
    'Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>'
  ],
  'dist_name' => 'Pinto',
  'dist_version' => '0.007',
  'license' => 'perl',
  'module_name' => 'Pinto',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'App::Cmd::Setup' => '0',
    'Carp' => '0',
    'Compress::Zlib' => '0',
    'Date::Format' => '0',
    'Dist::Metadata' => '0',
    'Exporter' => '0',
    'File::Copy' => '0',
    'File::Find' => '0',
    'File::HomeDir' => '0',
    'IPC::Cmd' => '0.72',
    'LWP::UserAgent' => '0',
    'List::MoreUtils' => '0',
    'Moose' => '0',
    'Moose::Autobox' => '0',
    'Moose::Role' => '0',
    'MooseX::Configuration' => '0',
    'MooseX::Types' => '0',
    'MooseX::Types::Moose' => '0',
    'Path::Class' => '0',
    'Path::Class::Dir' => '0',
    'Path::Class::File' => '0',
    'Readonly' => '0',
    'URI' => '0',
    'namespace::autoclean' => '0',
    'overload' => '0',
    'perl' => '5.008'
  },
  'script_files' => [
    'bin/pinto'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
