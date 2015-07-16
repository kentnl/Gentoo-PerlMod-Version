#!/usr/bin/env perl
# FILENAME: fatpack.pl
# CREATED: 07/17/15 08:20:40 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Fatpacks Gentoo::PerlMod::Version

use strict;
use warnings;

use App::FatPacker;
use Path::Tiny qw( path );
use Test::TempDir::Tiny qw( tempdir );
use Perl::Strip;

my $dir     = tempdir();
my $fatlib  = path( $dir, 'fatlib' )->absolute;
my $thinlib = path( $dir, 'lib' )->absolute;

$fatlib->mkpath;
$thinlib->mkpath;

my $packer = App::FatPacker->new();
my $root   = path(__FILE__)->parent->parent;

my $file   = $root->child( 'maint', 'gentoo-perlmod-version.pl' );
my $target = $root->child( 'bin',   'gentoo-perlmod-version.pl' );
my $srclib = $root->child('lib');

my $transformer = Perl::Strip->new( optimize_size => 0, keep_nl => 1 );
print "Generating a stripped lib in $thinlib\n";
$srclib->visit(
  sub {
    my ( $path, $state ) = @_;
    return if $path->is_dir;
    my $rpath  = $path->relative($srclib);
    my $target = $rpath->absolute($thinlib);
    $target->parent->mkpath;
    $target->spew_raw( $transformer->strip( $path->slurp_raw ) );
    print "cp:strip $path $target\n";
  },
  { recurse => 1 }
);
my (@pack) = qw(
  Sub/Exporter/Progressive.pm
);

print "Resolving packlists\n";
my (@packlists) = $packer->packlists_containing( \@pack );

print "Creating fatlib\n";
$packer->packlists_to_tree( "$fatlib", \@packlists );

print "Stripping fatlib\n";
$fatlib->visit(
  sub {
    my ( $path, $state ) = @_;
    return if $path->is_dir;
    $path->spew_raw( $transformer->strip( $path->slurp_raw ) );
    print "strip $path\n";
  },
  { recurse => 1 }
);

print "Packing Script\n";
my $shebang = "";
my $script  = "";
if ( defined $file and -r $file ) {
  ( $shebang, $script ) = $packer->load_main_script($file);
}

my (@dirs) = map { $_->absolute->stringify } $fatlib, $thinlib;

my %files;
$packer->collect_files( $_, \%files ) for @dirs;

my $content = join "\n", $shebang, "## no critic", $packer->fatpack_code( \%files ), "## use critic", $script;

$target->spew_raw($content);
