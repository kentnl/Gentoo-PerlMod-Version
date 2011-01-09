use strict;
use warnings;

package Gentoo::PerlMod::Version;

# ABSTRACT: Convert arbitrary Perl Modules' versions into normalised Gentoo versions.

use Sub::Exporter -setup => { exports => [qw( gentooize_version)] };
use Carp;
use List::MoreUtils qw( natatime );

=head1 SYNOPSIS


    use Gentoo::PerlMod::Version qw( :all );

    # http://search.cpan.org/~gmpassos/XML-Smart-1.6.9/
    say gentooize_version( '1.6.9' )  # 1.006.009

    http://search.cpan.org/~pip/Math-BaseCnv-1.6.A6FGHKE/

    say gentooize('1.6.A6FGHKE')   #  <-- death, this is awful

    # -- Work-In-Progress Features --

    say gentooize('1.6.A6FGHKE',{ lax => 1}) # <-- still death

    say gentooize('1.6.A6FGHKE',{ lax => 2}) # 1.006.366.556.632.014  # <-- the best we can do.

    say gentooize('1.9902-TRIAL')   #  <-- death, this is awful

    say gentooize('1.9902-TRIAL', { lax => 1 })   #  1.990.200 # <-- -TRIAL gets nuked.



=cut

=method gentooize_version

    my $normalized = gentoo_version( $weird_version )

gentooize_version tries hard to mangle a version thats part of a CPAN dist into a normalized form
for Gentoo.

Normal behaviour accepts only sane non-testing versions, and expands them to the form of \d(.\d\d\d)+ ie:

    0.1         -> 0.100
    0.001       -> 0.001
    1.1         -> 1.100
    1.123.13    -> 1.123.013

Etc.

This uses L<< C<version.pm>|version >> to read versions and to normalize them to floatingpoint form, and the floating point form
is sliced into arbitrary parts 3-digits long. ie:

    $x = version->parse( 0.01 )->numify;   # 0.010
    $x =~ s/(\.\d\d\d)(\d+)$/$1.$2/;       # 0.010
    $x = version->parse( 0.001 )->numify;  # 0.001
    $x =~ s/(\.\d\d\d)(\d+)$/$1.$2/;       # 0.001
    $x = version->parse( 0.0001 )->numify; # 0.000100
    $x =~ s/(\.\d\d\d)(\d+)$/$1.$2/;       # 0.000.100

So assuming Perl can handle your versions, they can be normalised.

=head3 lax level 1

    my $nomralized = gentoo_version( $werid_version, { lax => 1 } );

B<EXPERIMENTAL:> This feature is still in flux, and the emitted versions may change.

This adds one layer of laxitifity, and permits parsing and processing of "Developer Release" builds.





=cut

sub gentooize_version {
  my ( $perlver, $config ) = @_;
  $config ||= {};
  $config->{lax} = 0 unless defined $config->{lax};

  if ( not _has_bad_bits($perlver) ) {
    return _lax_cleaning_0($perlver);
  }

  if ( $config->{lax} eq 1 ) {
    return _lax_cleaning_1($perlver);
  }
  if ( $config->{lax} eq 2 ) {
    return _lax_cleaning_2($perlver);
  }

  Carp::croak("Invalid version format (non-numeric data). ( set { lax => } for more permissive behaviour )");
}

my $char_map = {
  ( map { $_ => $_ } 0 .. 9 ),    # 0..9
  ( map { chr( $_ + 65 ) => $_ + 10 } 0 .. 25 ),    # A-Z
  ( map { chr( $_ + 97 ) => $_ + 10 } 0 .. 25 )     # a-z
};

sub _char_map {
  require Data::Dumper;
  local $Data::Dumper::Sortkeys = 1;
  local $Data::Dumper::Terse    = 1;
  local $Data::Dumper::Indent   = 0;
  return Data::Dumper::Dumper($char_map);
}

sub _code_for {
  my $char = shift;
  if ( !exists $char_map->{$char} ) {
    Carp::croak( "Character $char ( " . ord($char) . ") is not in the ascii-to-int translation table" );
  }
  return $char_map->{$char};
}

sub _enc_pair {
  my (@tokens) = @_;
  if ( not @tokens ) {
    return '';
  }
  if ( @tokens < 2 ) {
    return _code_for( shift(@tokens) );
  }
  return ( _code_for( $tokens[0] ) * 36 ) + ( _code_for( $tokens[1] ) );
}

sub _ascii_to_int {
  my $string = shift;
  my @chars = split //, $string;
  my @output;

  my $iterator = natatime 2, @chars;
  while ( my @vals = $iterator->() ) {
    push @output, _enc_pair(@vals);
  }

  return join '.', @output;
}

sub _has_bad_bits {
  shift(@_) =~ /[^0-9.]/;
}

sub _lax_cleaning_0 {
    my $version = shift;
    return _expand_numeric( $version );
}


sub _lax_cleaning_1 {
  my $version = shift;
  my $istrial = 0;
  my $prereleasever = undef;

  if(  $version =~ s/-TRIAL$// ){
      $istrial = 1;
  }
  if( $version =~ s/_(.*)$/$1/ ){
     $prereleasever = "$1";
     if( $prereleasever =~ /_/ ){
         Carp::croak("More than one _ in a version is not permitted");
     }
  }
  $version = _expand_numeric( $version );
#  if( $istrial and not defined $prereleasever ){
#      $version .= '_pre001';
#  } elsif( defined $prereleasever ){
#      $prereleasever = _expand_numeric( '1.' . $prereleasever );
#      $prereleasever =~ s/^1.//;
#      $version .= '_pre' . $prereleasever;
#  }
  return $version;
}

sub _lax_cleaning_2 {
  my $version = shift;
  my $istrial = 0;

  if(  $version =~ s/-TRIAL$// ){
    $istrial = 1;
  }

  my @parts = split /([._])/, $version;
  my @out;
  for( @parts ) {
      if( $_ =~ /^[_.]$/ ){
          push @out, $_;
          next;
      }
      if( not _has_bad_bits($_ ) ){
          push @out, $_;
          next;
      }
      push @out, _ascii_to_int( $_ );
  }

  my $version_out = join q{}, @out;
  if( $istrial ){
      $version_out .= '-TRIAL';
  }
  return _lax_cleaning_1( $version_out );
}

sub _expand_numeric {
  my $perlver = shift;

  my $numeric = version->parse($perlver)->numify;

  1 while $numeric =~ s/(\.\d\d\d)(\d+)$/$1.$2/;

  return $numeric;
}


1;
