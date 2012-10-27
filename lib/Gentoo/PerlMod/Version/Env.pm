use strict;
use warnings;

package Gentoo::PerlMod::Version::Env;

# ABSTRACT: Get/parse settings from %ENV

my $state;
my $env_key = 'GENTOO_PERLMOD_VERSION_OPTS';

#
# my $hash = Gentoo::PerlMod::Version::Env::opts();
#
sub opts {
  return $state if defined $state;
  $state = {};
  return $state if not defined $ENV{$env_key};
  my (@tokes) = split /\s+/, $ENV{$env_key};
  for my $token (@tokes) {
    if ( $token =~ /^([^=]+)=(.+)$/ ) {
      $state->{"$1"} = "$2";
    }
    elsif ( $token =~ /^-(.+)$/ ) {
      delete $state->{"$1"};
    }
    else {
      $state->{$token} = 1;
    }
  }
  return $state;
}

#
# GENTOO_PERLMOD_VERSION=" foo=5 ";
#
# my $value = _env_hasopt( 'foo' );
# ok( $value );
#

sub hasopt {
  my ($opt) = @_;
  return exists opts()->{$opt};
}

#
# GENTOO_PERLMOD_VERSION=" foo=5 ";
#
# my $value = _env_getopt( 'foo' );
# is( $value, 5 );
#
sub getopt {
  my ($opt) = @_;
  return opts()->{$opt};
}

1;
