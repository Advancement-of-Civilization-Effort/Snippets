== README ==

Binary 2 Ascii conversion:
--------------------------

Module : ACE::BaseNN

Generic code for encoding / decoding a binary of data in an ascii string.
multiple alphabet are possible

Usage:
------
use ACE::BaseNN qw(encode_base decode_base);

``my $alphabet = join'',('@','a' .. 'z','.');

my $data = pack('H*','33553b95035cc20573b9e32584002aa2949bad441e462f28c307b8372f'); 
my $enc = &encode_base($data,$alphabet);
print $enc,"\n";

print &decode_base('ormfjwtu',$alphabet),"\n";
``

Requirement:
------------
Math::BigInt





file encode58 is this original code snippet before packaging ...

