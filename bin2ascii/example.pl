use ACE::BaseNN qw(encode_base decode_base);

my $alphabet = join'',('@','a' .. 'z','.');
my $data = pack('H*','33553b95035cc20573b9e32584002aa2949bad441e462f28c307b8372f'); 
my $enc = &encode_base('12345',$alphabet);
print $enc,"\n";
printf "alphabet: %s (radix: #%u)\n",$alphabet,length($alphabet);
my $data = &decode_base('ormfjwtu',$alphabet);
print $data,"\n";

1;
