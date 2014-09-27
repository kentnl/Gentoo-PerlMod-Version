use 5.006;
use strict;
use warnings;

package Gentoo::PerlMod::Version::Env;

our $VERSION = '0.7.0';

# ABSTRACT: Get/parse settings from %ENV

my $state;
my $env_key = 'GENTOO_PERLMOD_VERSION_OPTS';

=func opts

    my $hash = Gentoo::PerlMod::Version::Env::opts();

=cut

sub opts {
  return $state if defined $state;
  $state = {};
  return $state if not defined $ENV{$env_key};
  my (@tokes) = split /\s+/msx, $ENV{$env_key};
  for my $token (@tokes) {
    if ( $token =~ /\A([^=]+)=(.+)\z/msx ) {
      $state->{"$1"} = "$2";
    }
    elsif ( $token =~ /\A-(.+)\z/msx ) {
      delete $state->{"$1"};
    }
    else {
      $state->{$token} = 1;
    }
  }
  return $state;
}

=func hasopt

    GENTOO_PERLMOD_VERSION=" foo=5 ";

    if ( Gentoo::PerlMod::Version::Env::hasopt('foo') ) {
        pass('has opt foo');
    }

=cut

sub hasopt {
  my ($opt) = @_;
  return exists opts()->{$opt};
}

=func getopt

    GENTOO_PERLMOD_VERSION=" foo=5 ";

    if ( Gentoo::PerlMod::Version::Env::hasopt('foo') ) {
        is( Gentoo::PerlMod::Version::Env::getopt('foo'), 5 , ' foo == 5' );
    }

=cut

sub getopt {
  my ($opt) = @_;
  return opts()->{$opt};
}

1;
