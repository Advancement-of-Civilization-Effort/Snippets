#!perl

local $| = 1;
use ACE::BaseNN qw(encode_base decode_base);

my $alphabet = join'',grep!/[0OlI]/,split//,
  '-0123456789'. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
                 'abcdefghijklmnopqrstuwvxyz'.
  q/+.@$%_,~`'=;!^[]{}()#&/. #
  '<>:"/\\|?*'; #;

#$alphabet = '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ@.';

printf "radix: %u\n",length($alphabet);
my $i = 0;
while (--$i) {
 my $e = &encode_base(pack('N',$i),$alphabet);
 my $n = hex unpack'H*',&decode_base($e,$alphabet);
 printf "%d: %s -> %s\r",$i,$n,$e;

}

1;
