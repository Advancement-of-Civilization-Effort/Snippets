#!perl
#
# this script has 2 generic encode/decode function that work
# with any passed alphabet !
#
#
# vim: nowrap ts=2 et noai
use Math::BigInt;

my $IPFSalphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

if ($0 eq __FILE__) {
my $e = '987654321ABC';
my $a = &decode_base($e,$IPFSalphabet);
printf "%s -> %s\n",$e,unpack('H*',$a);
my $e2 = &encode_base($a,$IPFSalphabet);
printf "%s -> %s\n",unpack('H*',$a),$e2;
die if ($e ne $e2);

sleep 3;
exit $?;
}

sub decode_base {
	my ($s,$alphab) = @_;
  my $radix = Math::BigInt->new(length($alphab));
  printf "// %s : #%s\n",$alphab,$radix if $dbug;
  my $n = Math::BigInt->new(0);
  my $j = Math::BigInt->new(1);

  my @s = split //,$s;

  my $l = 0;
  while($s ne '') {
    my $c = substr($s,-1,1,''); # consume chr from the end !
    my $i = index($alphab,$c);
    return '' if ($i < 0);
    printf "%u: j=%s '%s' (%d)",$l++,$j,$c,$i if $dbug;
    $w = $j->copy();
    $w->bmul($i);
    $n->badd($w);
    printf " w=%s n=%s\n",$w,$n if $dbug;
    $j = Math::BigInt->bmul($j,$radix);
  }
  my $h = $n->as_hex();
  my $d = int( (length($h)+1-2)/2 ) * 2;

  # byte alignment ...
  $h = substr('0' x $d . substr($h,2),-$d);
  return pack('H*',$h);
}

sub encode_base {
	my ($d,$alphab) = @_;
  my $radix = Math::BigInt->new(length($alphab));
  printf "// %s : #%s\n",$alphab,$radix if $dbug;
  my $e = '';
  my $h = unpack('H*',$d);
  my $n = Math::BigInt->from_hex("0x$h");
  printf "h=%s n=%s\n",$h,$n if $dbug;
  my $l = 0;
  while ($n->bcmp(0) == +1)  {
    my $c = Math::BigInt->new();
    my ($n,$c) = $n->bdiv($radix);
    $e .= substr($alphab,$c->numify,1);
    printf "%u: n=%s c=%s e='%s'\n",$l++,$n,$c,$e if $dbug;
  }
  return reverse $e;
  
}

1; # $Source: /my/perl/script/at/ACE/encode58.pl,v $
