use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;
use Gentoo::PerlMod::Version qw( :all );

sub b {
  my ( $z, $x, $y ) = @_;
  is( gentooize_version($x), $y, "$x -> $y expanding ( icode $z )" );
}

# 1..10
b( 1,  '0',        '0.000' );
b( 2,  '1',        '1.000' );
b( 3,  '0.1',      '0.100' );
b( 4,  '1.1',      '1.100' );
b( 5,  '0.01',     '0.010' );
b( 6,  '1.01',     '1.010' );
b( 7,  '1.001',    '1.001' );
b( 8,  '1.0001',   '1.000.100' );
b( 9,  '1.00001',  '1.000.010' );
b( 10, '1.000001', '1.000.001' );
;    # 10 .. 19
b( 11, '1.0000001',      '1.000.000.100' );
b( 12, '1.00000001',     '1.000.000.010' );
b( 13, '1.000000001',    '1.000.000.001' );
b( 14, '1.0000000001',   '1.000.000.000.100' );
b( 15, '1.00000000001',  '1.000.000.000.010' );
b( 16, '1.000000000001', '1.000.000.000.001' );
b( 17, '1.0.1',          '1.000.001' );
b( 18, '1.0.01',         '1.000.001' );
b( 19, '1.0.001',        '1.000.001' );
b( 20, '1.0.10',         '1.000.010' );
;    # 20 .. 29
b( 21, '1.0.010',          '1.000.010' );
b( 22, '1.0.0010',         '1.000.010' );
b( 23, '1.1.1',            '1.001.001' );
b( 24, '1.1.01',           '1.001.001' );
b( 25, '1.1.001',          '1.001.001' );
b( 26, '1.1.10',           '1.001.010' );
b( 27, '1.1.010',          '1.001.010' );
b( 28, '1.1.0010',         '1.001.010' );
b( 29, '1.1.000000000010', '1.001.010' );
b( 30, '1.10.1',           '1.010.001' );
;    # 30 .. 39
b( 31, '1.10.01',           '1.010.001' );
b( 32, '1.10.001',          '1.010.001' );
b( 33, '1.10.10',           '1.010.010' );
b( 34, '1.10.010',          '1.010.010' );
b( 35, '1.10.0010',         '1.010.010' );
b( 36, '1.10.000000000010', '1.010.010' );
b( 37, '1.010.1',           '1.010.001' );
b( 38, '1.010.01',          '1.010.001' );
b( 39, '1.010.001',         '1.010.001' );
b( 40, '1.010.10',          '1.010.010' );
;    # 40 .. 49
b( 41, '1.010.010',          '1.010.010' );
b( 42, '1.010.0010',         '1.010.010' );
b( 43, '1.010.000000000010', '1.010.010' );

my $e;
isnt( $e = exception { gentooize_version('1.6.A6FGHKE') }, undef, 'Ascii is bad' );     # 44
isnt( $e = exception { gentooize_version('1.6-TRIAL') },   undef, '-TRIAL is bad' );    # 45
isnt( $e = exception { gentooize_version('1.6_0') },       undef, 'x_y is bad' );       # 46
isnt( $e = exception { gentooize_version( '1.6.A6FGHKE', { lax => 1 } ) }, undef, 'Ascii is bad ( even with lax => 1 )' );    # 47
is( $e = exception { gentooize_version( '1.6-TRIAL',   { lax => 1 } ) }, undef, '-TRIAL is ok with lax => 1' );               # 48
is( $e = exception { gentooize_version( '1.6_0',       { lax => 1 } ) }, undef, 'x_y is ok with lax => 1 ' );                 # 49
is( $e = exception { gentooize_version( '1.6.A6FGHKE', { lax => 2 } ) }, undef, 'Ascii is ok with lax => 2 )' );              # 50
is( $e = exception { gentooize_version( '1.6-TRIAL',   { lax => 2 } ) }, undef, '-TRIAL is ok with lax => 2' );               # 51
is( $e = exception { gentooize_version( '1.6_0',       { lax => 2 } ) }, undef, 'x_y is ok with lax => 2 ' );                 # 52

is( gentooize_version( '1.6-TRIAL',   { lax => 1 } ), '1.600',     'x.y-TRIAL' );                                             # 53
is( gentooize_version( '1.67-TRIAL',  { lax => 1 } ), '1.670',     'x.yy-TRIAL' );                                            # 54
is( gentooize_version( '1.675-TRIAL', { lax => 1 } ), '1.675',     'x.yyy-TRIAL' );                                           # 55
is( gentooize_version( '1.6_01',      { lax => 1 } ), '1.601',     'x.y_z' );                                                 # 56
is( gentooize_version( '1.67_01',     { lax => 1 } ), '1.670.100', 'x.yy_zz' );                                               # 57
is( gentooize_version( '1.675_01',    { lax => 1 } ), '1.675.010', 'x.yyy_zz' );                                              # 58

isnt( $e = exception { gentooize_version( '1.6_01_01', { lax => 1 } ) }, undef, 'x.y_z_a fails' );                            # 59
is( gentooize_version( '1.6.A',    { lax => 2 } ), '1.006.010',     'x.y.ASCII' );                                            # 60
is( gentooize_version( '1.6.AA',   { lax => 2 } ), '1.006.370',     'x.y.ASCII' );                                            # 61
is( gentooize_version( '1.6.AAA',  { lax => 2 } ), '1.006.370.010', 'x.y.ASCII' );                                            # 62
is( gentooize_version( '1.6.AAAA', { lax => 2 } ), '1.006.370.370', 'x.y.ASCII' );                                            # 63

done_testing;
