#!perl
# vim: ts=2 et noai nowrap

package ACE::Util;
# ----------------------------------------------------
# Note:
#   This work was done during time spent at ACE
# 
# -- Copyright ACE, 2015,2016 --
# ----------------------------------------------------
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
if (! -f '/dev/null') { # non-unix system
sub getpwuid ();
}

if ($0 eq __FILE__) {
  printf "testing $0\n";
  printf " %s / %s . %s\n",&basen($0);
  exit $?;
}


# -----------------------------------------------------
sub basen { # extrac basename etc...
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
  
  $basen =~ s/(F[0-9]{5}|[a-f0-9]{7})[0-9]{4,8}\s+[0-9]{4}_[0-9]{5}$/\1/;
  $basen =~ s/\s+([a-z]{5}-)?v[0-9.]{4}$//; # remove version ...
  
  $basen =~ s/\s+[0-9]{4}_[0-9]{5}$//;
  $basen =~ s/\s-\s[A-Z0-9]{4}$//;
  $basen =~ s/\s[a-f0-9]{7}$//;
  $basen =~ s/\s+\(\d+\)$//;
  $basen =~ s/\s*\(.*[Cc]onflicted[^)]*\)$//;
  $basen =~ s/_conflict-\d+-\d+$//;
  $basen =~ s/\s+[b-z][aeiouy][a-z][aeiouy][b-z]$//;   

  return ($fpath,$basen,$ext);

  }

}
# -----------------------------------------------------
sub copy ($$) {
 my ($src,$trg) = @_;
 local *F1, *F2;
 return undef unless -r $src;
 return undef if (-e $trg && ! -w $trg);
 open F2,'>',$trg or warn "-w $trg $!"; binmode(F2);
 open F1,'<',$src or warn "-r $src $!"; binmode(F1);
 local $/ = undef;
 my $tmp = <F1>; print F2 $tmp;
 close F1;

 my ($atime,$mtime,$ctime) = (lstat(F1))[8,9,10];
 #my $etime = ($mtime < $ctime) ? $mtime : $ctime;
 utime($atime,$mtime,$trg);
 close F2;
 return $?;
}
# -----------------------------------------------------
1; # $Source: /my/perl/modules/at/ACE/Util.pm,v $
