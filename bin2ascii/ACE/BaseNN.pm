#!perl
# vim: ts=2 et noai nowrap

package ACE::BaseNN;
# Note:
#   This work has been done during my time HEIG-VD
#   65% employment (CTI 13916)
# 
# -- Copyright HEIG-VD, 2014,2015 --

# -----------------------------------------------------
require Exporter;
@ISA = qw(Exporter);
# Subs we export by default.
@EXPORT = qw();
# Subs we will export if asked.
#@EXPORT_OK = qw(nickname);
@EXPORT_OK = grep { $_ !~ m/^_/ && defined &$_; } keys %{__PACKAGE__ . '::'};

use strict;
# The "use vars" and "$VERSION" statements seem to be required.
use vars qw/$dbug $VERSION/;
# ----------------------------------------------------
local $VERSION = sprintf "%d.%02d", q$Revision: 0.0 $ =~ /: (\d+)\.(\d+)/;
my ($State) = q$State: Exp $ =~ /: (\w+)/; our $dbug = ($State eq 'dbug')?1:0;
# ----------------------------------------------------

# alphabet: abcdefghijklmnopqrstuvwxyz {}!(),#;&- 0-9 (26*2+10)
# bitcoin: 123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
#
our $alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
if ($0 eq __FILE__) {
  die if ( &decode_base(&encode_base('abcd',$alphabet),$alphabet) ne 'abcde')
}

# -----------------------------------------------------
sub decode_base {
  use Math::BigInt;
  my ($s,$alphab) = @_;
  my $radix = Math::BigInt->new(length($alphab));
  my $n = Math::BigInt->new(0);
  my $j = Math::BigInt->new(1);
  while($s ne '') {
    my $c = substr($s,-1,1,''); # consume chr from the end !
    my $i = index($alphab,$c);
    return '' if ($i < 0);
    my $w = $j->copy();
    $w->bmul($i);
    $n->badd($w);
    $j->bmul($radix);
  }
  my $h = $n->as_hex();
  # byte alignment ...
  my $d = int( (length($h)+1-2)/2 ) * 2;
  $h = substr('0' x $d . substr($h,2),-$d);
  return pack('H*',$h);
}

sub encode_base {
  use Math::BigInt;
  my ($d,$alphab) = @_;
  my $radix = Math::BigInt->new(length($alphab));
  my $h = '0x'.unpack('H*',$d);
  my $n = Math::BigInt->from_hex($h);
  my $e = '';
  while ($n->bcmp(0) == +1)  {
    my $c = Math::BigInt->new();
    my ($n,$c) = $n->bdiv($radix);
    $e .= substr($alphab,$c->numify,1);
  }
  return reverse $e;
}

# -----------------------------------------------------
1; # $Source: /my/perl/modules/at/ACE/PBaseNN.pm,v $
