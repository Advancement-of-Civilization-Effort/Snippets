#!perl

my $fullname = shift;
my $chrome = %ENV{'ProgramFiles(x86)'}.'\Google\Chrome\Application\chrome.exe';

my ($fpath,$basen,$ext) = &basen($fullname);

my $file = sprintf '%s.%s',$basen,$ext;
my $bfile = sprintf '%s-bakup.%s',$basen,$ext; # backup file

my $file1 = sprintf '%s (1).%s',$basen,$ext; # downloaded file
my $download = $ENV{USERPROFILE}.'/Downloads';

if (-e $file) {
unlink $bfile;
rename $file, $bfile or warn $!;
print "backup: $bfile ($fpath)\n";
link $bfile, "$download/$file" unless (-e "$download/$file");
}



if (-e "$download/$file1" ) {
print "-e Downloads/$file1\n";
unlink "$download/$file";
link "$download/$file1", "$download/$file";
unlink "$download/$file1";
}

if (-e "$download/$file" ) {
print "-e Downloads/$file\n";
unlink $file;
link "$download/$file", $file;
}

system sprintf '"%s" "%s"',$chrome,$fullname;
sleep 5;
exit $?;

sub basen { # extract basename etc...
  my $f = shift;
  $f =~ s,\\,/,g; # *nix style !
  my $s = rindex($f,'/');
  my $fpath = ($s > 0) ? substr($f,0,$s) : '.';
  my $file = substr($f,$s+1);

  if (-d $f) {
    return ($fpath,$file);
  } else {
  my $p = rindex($file,'.');
  my $basen = ($p>0) ? substr($file,0,$p) : $file;
  my $ext = lc substr($file,$p+1);
     $ext =~ s/\~$//;
  
  $basen =~ s/\s*\(.*[Cc]onflicted[^)]*\)$//;
  $basen =~ s/_conflict-\d+-\d+$//;

  return ($fpath,$basen,$ext);

  }

}
1;
