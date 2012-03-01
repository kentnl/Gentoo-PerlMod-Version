
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Test::Fatal" => 0,
    "Test::More" => "0.96"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Convert arbitrary Perl Modules' versions into normalised Gentoo versions.",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "Gentoo-PerlMod-Version",
  "dist_version" => "0.4.0",
  "license" => "perl",
  "module_name" => "Gentoo::PerlMod::Version",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "Data::Dumper" => 0,
    "List::MoreUtils" => 0,
    "Sub::Exporter" => 0,
    "perl" => "5.10.0",
    "strict" => 0,
    "version" => "0.77",
    "warnings" => 0
  },
  "script_files" => [
    "bin/gentoo-perlmod-version.pl"
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
