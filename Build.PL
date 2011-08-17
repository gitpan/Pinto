
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'ExtUtils::MakeMaker' => '6.30',
    'File::Temp' => '0',
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'Test::Exception' => '0',
    'Test::File' => '0',
    'Test::More' => '0',
    'Test::Warn' => '0'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Perl distribution repository manager',
  'dist_author' => [
    'Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>'
  ],
  'dist_name' => 'Pinto',
  'dist_version' => '0.014',
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
    'Dist::Metadata' => '0',
    'English' => '0',
    'File::Copy' => '0',
    'File::Find' => '0',
    'LWP::UserAgent' => '0',
    'List::MoreUtils' => '0',
    'Moose' => '0',
    'Moose::Autobox' => '0',
    'Moose::Role' => '0',
    'MooseX::Types::Moose' => '0',
    'Path::Class' => '0',
    'PerlIO::gzip' => '0',
    'Pinto::Config' => '0',
    'Pinto::Logger' => '0',
    'Pinto::Role::Configurable' => '0.013',
    'Pinto::Role::Loggable' => '0.013',
    'Pinto::Types' => '0',
    'Proc::Reliable' => '0',
    'Readonly' => '0',
    'Try::Tiny' => '0',
    'URI' => '0',
    'autodie' => '0',
    'namespace::autoclean' => '0',
    'overload' => '0',
    'perl' => '5.006'
  },
  'script_files' => [
    'bin/pinto-admin',
    'bin/pinto-client'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
