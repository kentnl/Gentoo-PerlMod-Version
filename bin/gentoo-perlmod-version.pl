#!/usr/bin/env perl


use strict;
use warnings;

package Gentoo::PerlMod::Version::Tool;
BEGIN {
  $Gentoo::PerlMod::Version::Tool::VERSION = '0.3.0';
}

# PODNAME: gentoo-perlmod-version.pl
# ABSTRACT: Command line utility for translating cpan versions to gentoo equivalents.

## no critic (ProhibitPunctuationVar)
use Gentoo::PerlMod::Version qw( :all );
use Carp qw( croak );
my $lax = 0;


for (@ARGV) {
  if ( $_ =~ /^--?h/ ) {
    die <<"EOF";

    gentoo-perlmod-version.pl 1.4 1.5 1.6
    gentoo-perlmod-version.pl --lax=1 1.4_5 1.5_6
    gentoo-perlmod-version.pl --lax=2 1.4.DONTDOTHISPLEASE432

    echo 1.4 | gentoo-perlmod-version.pl
    echo 1.4-5 | gentoo-perlmod-version.pl --lax=1
    echo 1.4.NOOOOO | gentoo-perlmod-version.pl --lax=2

EOF

  }
}
for ( 0 .. $#ARGV ) {

  if ( $ARGV[$_] =~ /^--lax=(\d+)$/ ) {
    $lax = 0 + $1;
    splice @ARGV, $_, 1, ();
    last;
  }
}

if (@ARGV) {
  for (@ARGV) {
    print "$_ => " . gentooize_version( $_, { lax => $lax } ) or croak "Print Error $1";
    print "\n" or croak "Print Error $!";
  }
}
else {
  while (<>) {
    chomp;
    print "$_ => " . gentooize_version( $_, { lax => $lax } ) or croak "Print error $!";
    print "\n" or croak "Print error $!";
  }
}


__END__
=pod

=head1 NAME

gentoo-perlmod-version.pl - Command line utility for translating cpan versions to gentoo equivalents.

=head1 VERSION

version 0.3.0

=head1 SYNOPSIS

    gentoo-perlmod-version.pl 1.4 1.5 1.6
    gentoo-perlmod-version.pl --lax=1 1.4_5 1.5_6
    gentoo-perlmod-version.pl --lax=2 1.4.DONTDOTHISPLEASE432

    echo 1.4 | gentoo-perlmod-version.pl
    echo 1.4-5 | gentoo-perlmod-version.pl --lax=1
    echo 1.4.NOOOOO | gentoo-perlmod-version.pl --lax=2

See perldoc for L<< C<Gentoo::PerlMod::Versions> documentation|Gentoo::PerlMod::Version >> for more information.

    perldoc Gentoo::PerlMod::Version

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

