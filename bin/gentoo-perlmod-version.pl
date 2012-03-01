#!/usr/bin/env perl

use strict;
use warnings;

package Gentoo::PerlMod::Version::Tool;

# PODNAME: gentoo-perlmod-version.pl
# ABSTRACT: Command line utility for translating cpan versions to gentoo equivalents.

## no critic (ProhibitPunctuationVar)
use Gentoo::PerlMod::Version qw( :all );
use Carp qw( croak );

=head1 SYNOPSIS

    gentoo-perlmod-version.pl 1.4 1.5 1.6
    gentoo-perlmod-version.pl --lax=1 1.4_5 1.5_6
    gentoo-perlmod-version.pl --lax=2 1.4.DONTDOTHISPLEASE432

    echo 1.4 | gentoo-perlmod-version.pl
    echo 1.4-5 | gentoo-perlmod-version.pl --lax=1
    echo 1.4.NOOOOO | gentoo-perlmod-version.pl --lax=2

    SOMEVAR="$(  gentoo-perlmod-version.pl --oneshot 1.4 )"
    SOMEVAR="$(  gentoo-perlmod-version.pl --oneshot 1.4 1.5 )" # Invalid, dies
    SOMEVAR="$(  gentoo-perlmod-version.pl --oneshot 1.4_5 )" # Invalid, dies
    SOMEVAR="$(  gentoo-perlmod-version.pl --lax=1 --oneshot 1.4_5 )" # Ok


See perldoc for L<< C<Gentoo::PerlMod::Versions> documentation|Gentoo::PerlMod::Version >> for more information.

    perldoc Gentoo::PerlMod::Version

=cut

for (@ARGV) {
  if ( $_ =~ /^--?h/ ) {
    die <<"EOF";

    gentoo-perlmod-version.pl 1.4 1.5 1.6
    gentoo-perlmod-version.pl --lax=1 1.4_5 1.5_6
    gentoo-perlmod-version.pl --lax=2 1.4.DONTDOTHISPLEASE432

    echo 1.4 | gentoo-perlmod-version.pl
    echo 1.4-5 | gentoo-perlmod-version.pl --lax=1
    echo 1.4.NOOOOO | gentoo-perlmod-version.pl --lax=2

    SOMEVAR="\$(  gentoo-perlmod-version.pl --oneshot 1.4 )"
    SOMEVAR="\$(  gentoo-perlmod-version.pl --oneshot 1.4 1.5 )" # Invalid, dies
    SOMEVAR="\$(  gentoo-perlmod-version.pl --oneshot 1.4_5 )" # Invalid, dies
    SOMEVAR="\$(  gentoo-perlmod-version.pl --lax=1 --oneshot 1.4_5 )" # Ok


See perldoc for Gentoo::PerlMod::Version for more information.

    perldoc Gentoo::PerlMod::Version

EOF

  }
}

my $lax     = 0;
my $oneshot = 0;

for ( 0 .. $#ARGV ) {
  next unless $ARGV[$_] =~ /^--lax=(\d+)$/;
  $lax = 0 + $1;
  splice @ARGV, $_, 1, ();
  last;
}
for ( 0 .. $#ARGV ) {
  next unless $ARGV[$_] =~ /^--oneshot$/;
  $oneshot = 1;
  splice @ARGV, $_, 1, ();
  last;
}

if ($oneshot) {
  die "Too many versions given to --oneshot mode" if $#ARGV > 0;
  my $v = gentooize_version( $ARGV[0], { lax => $lax } );
  print $v or die "Print Error $!";
  exit 0;
}

if (@ARGV) {
  for (@ARGV) {
    map_version( $_, $lax );
  }
}
else {
  while (<>) {
    chomp;
    map_version( $_, $lax );
  }
}

sub map_version {
  my ( $version, $laxness ) = @_;
  print "$version => " . gentooize_version( $version, { lax => $laxness } ) or croak "Print error $!";
  print "\n" or croak "Print error $!";
}

