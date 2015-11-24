#!/usr/bin/perl

use strict;

sub do_maxima_to_tex {
  my $m = shift;
  my $c = "maxima --batch-string='exptdispflag:false; print(tex1($m))\$'";
  my $e = `$c`;
  my @x = split(/\(%i\d+\)/,$e); # output contains stuff like (%i1) 
  my $f = pop @x;  # remove everything before the echo of the last input
  while ($f=~/\A /) {$f=~s/\A .*\n//} # remove echo of input, which may be more than one line
  $f =~ s/\\\n//g; # maxima breaks latex tokens in the middle at end of line; fix this
  $f =~ s/\n/ /g; # if multiple lines, get it into one line
  $f =~ s/\s+\Z//; # get rid of final whitespace
  return $f;
}

sub differentiate {
  my $m = shift;
  my $c = "maxima --batch-string='exptdispflag:false; grind(diff($m,t))\$'";
  my $e = `$c`;
  my @x = split(/\(%i\d+\)/,$e); # output contains stuff like (%i1) 
  my $f = pop @x;  # remove everything before the echo of the last input
  while ($f=~/\A /) {$f=~s/\A .*\n//} # remove echo of input, which may be more than one line
  $f =~ s/\\\n//g; # maxima breaks latex tokens in the middle at end of line; fix this
  $f =~ s/\n/ /g; # if multiple lines, get it into one line
  $f =~ s/\s+\Z//; # get rid of final whitespace
  $f =~ s/\$\Z//; # get rid of final $
  return $f;
}

sub evaluate_at {
  my $m = shift;
  my $at = shift;
  my $c = "maxima --batch-string='exptdispflag:false; f(t):=''($m); print(tex1(f($at)))\$'";
  my $e = `$c`;
  my @x = split(/\(%i\d+\)/,$e); # output contains stuff like (%i1) 
  my $f = pop @x;  # remove everything before the echo of the last input
  while ($f=~/\A /) {$f=~s/\A .*\n//} # remove echo of input, which may be more than one line
  $f =~ s/\\\n//g; # maxima breaks latex tokens in the middle at end of line; fix this
  $f =~ s/\n/ /g; # if multiple lines, get it into one line
  $f =~ s/\s+\Z//; # get rid of final whitespace
  return $f;
}

foreach my $a (
    ["a*cos(b*exp(-c*sin(k*t)))",0],
    ["-a*exp(-2*b*sqrt(c+k*sin(w*t)))",0],
    ["b*cos(((c*t)^3)/(sin(k*t)))",1],
    ["a*tan((b*t)/(cos((t/c)^2)))",0],
    ["(1/(a*sin(b/log(c*t))))^4",1],
    ["a*log(b+c*tan(2^(k*t)))",0],
  ) {

  #print "---------------------------\n";

  my $expr = $a->[0];
  my $at = $a->[1];

  #print "input expression = $expr, at $at\n";

  my $e0 = do_maxima_to_tex($expr);
  #print "input expression in tex = $e0\n";

  my $e1 = do_maxima_to_tex("diff($expr,'t')");
  #print $e1,"\n";

  my $e2 = differentiate($expr);
  #print $e2,"\n";
  if ($e1=~/encountered a Lisp error/) {$e1=''}
  my $e3 = evaluate_at($e2,$at);

  #print "\$f(t)=$e0\$ \\\\\n";
  print "\$f'(t)=$e1\$ \\\\\n";
  print "\$f'($at)=$e3\$ \\\\\n";
  print "\\vspace{4mm}\n";

}
