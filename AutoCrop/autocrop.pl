@:=' -- $RCSfile: autocrop.pl,v $
@start c:\strawberry\perl\bin\perl.exe -x -S %0 %* & goto endofperl '; # vim: filetype=perl nowrap
#!perl
#line 5

# @(#) image autocroping :
#   this code crop an greyscale image automatically using a threshold
#
#   set to 40% of average level
my $thres = 0.40;
#  
#
#
# currently run on Windows only due to $pwd call !
#
# will make the port such that OSX
#    and *nix people can run it too
#
# dependencies: 
#   PDL
#   PDL::NiceSlice
#   PDL::Graphics::Gnuplot
#   ACE::Util for &basen routine
#
#   also need djpeg conversion tools in the path to allow proper reading of input images ...
#
# Tue 11/10/15 : 1447167545,56420639 (D314 15:59 Nov,10 - W46)
#
my ($STATE) = q$State: dbug $ =~ /: (\w+)/; our $dbug = ($STATE eq 'dbug')?1:0;
sub say { local $\ = "\n", print @_ if $dbug; }

use ACE::Util qw(basen);

$| = 1;
our $verbose = 1;
eval { our $pwd = Win32::GetCwd() }; # current directory

use PDL;
use PDL::NiceSlice; # MATLAB style of arrays ...

my $file = shift || 'example.jpg'; # if no argument is passed use example.jpg
my $fdir = $pwd;

my @images = ($file);

my $pix = undef;
foreach my $filename (@images) {
  $file = $fdir.'\\'.$filename;

  my ($fpath,$basen,$ext) = &basen($file);
  $cropfile = "${basen}_cropped.$ext"; # results

  # ---------------------------------------------
  # convert to grey scale :
  #
  my $yc = pdl( [.299,.587,.114] ); # primaries sensitivity coefficients ...
  our $pix = inner($yc,rpic($file));
  ($xsize, $ysize) = dims($pix);
  printf "%s: %ux%u\n",$basen,$xsize,$ysize;
  say $pix->info;
  # ---------------------------------------------
  # use the average brightness to determine ROI
  my $level = avg($pix) * $thres;
  my $mask = $pix>$level;
  use PDL::Graphics::Gnuplot qw(image); image $mask;

  my ($xmin,$xmax) = (undef,undef);
  my ($ymin,$ymax) = (undef,undef);
  # ---------------------------------------------
  # first algo: minmax approach ...
  my $tic = time();
  for (1 .. 1000) {
  my ($p0,$p1) = minmax(which($mask));
  my ($q0,$q1) = minmax(which(mv($mask,1,0)) );
  $ymin = int($p0 / $xsize);
  $ymax = int($p1 / $xsize);

  $xmin = int($q0 / $ysize);
  $xmax = int($q1 / $ysize);
  }
  printf "algo 1: speed= %f\n",1000/(time() - $tic);
  # ---------------------------------------------
  print "xmin,ymin = $xmin,$ymin\n";
  print "xmax,ymax = $xmax,$ymax\n";

  # ---------------------------------------------
  # second algo: "reduced" for loops
  my $tic = time();
  for (1 .. 1000) {
  ($ymin,$ymax) = (undef,undef);
  for my $j (0 .. $ysize-1) {
    my $k = $ysize-1 - $j;
    #printf "row%u: %u\n",$j,nelem(which($ppm->slice(":,($j)")));
    if (! defined $ymin && nelem(which($mask->slice(":,($j)"))) ) { $ymin = $j; last if defined $ymax; }
    if (! defined $ymax && nelem(which($mask->slice(":,($k)"))) ) { $ymax = $k; last if defined $ymin; }
  }
  ($xmin,$xmax) = (undef,undef);
  for my $i (0 .. $xsize-1) {
    my $l = $xsize-1 - $i;
    #printf "col%u: %u %u %u\n",$i,nelem(which($ppm->slice("($i),:"))),$xmin,$xmax;
    if (! defined $xmin && nelem(which($mask->slice("($i),:")))) { $xmin = $i; last if defined $xmax; }
    if (! defined $xmax && nelem(which($mask->slice("($l),:")))) { $xmax = $l; last if defined $xmin; }
  }
  }
  printf "algo 2: speed= %f\n",1000/(time() - $tic);
  # ---------------------------------------------
  printf "y: min=%u, max=%u\n",$ymin,$ymax;
  printf "x: min=%u, max=%u\n",$xmin,$xmax;

  # ---------------------------------------------
  # third algo: hybrid !
  my $tic = time();
  for (1 .. 1000) {
  my ($p0,$p1) = minmax(which($mask));
  $ymin = int($p0 / $xsize);
  $ymax = int($p1 / $xsize);
  ($xmin,$xmax) = (undef,undef);
  for my $i (0 .. $xsize-1) {
    my $l = $xsize-1 - $i;
    #printf "col%u: %u %u %u\n",$i,nelem(which($ppm->slice("($i),:"))),$xmin,$xmax;
    if (! defined $xmin && nelem(which($mask->slice("($i),:")))) { $xmin = $i; last if defined $xmax; }
    if (! defined $xmax && nelem(which($mask->slice("($l),:")))) { $xmax = $l; last if defined $xmin; }
  }
  }
  printf "algo 3: speed= %f\n",1000/(time() - $tic);
  # ---------------------------------------------
  print "ymin,ymax = $ymin,$ymax\n";
  printf "x: min=%u, max=%u\n",$xmin,$xmax;




  #return; # <--------------------------
  my $ROI = sprintf '%u:%u,%u:%u',$xmin,$xmax,$ymin,$ymax;
  my $cropped = $pix($ROI);
  wpic($cropped,$cropfile);

}

exit $?;

1;
__END__
:endofperl
