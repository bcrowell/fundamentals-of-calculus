#!/usr/bin/perl

use strict;

# This script:
#        - writes a file such as book.labels containing a list of labels for spotter
#        - rebuilds the spotter file book.xml from book.m4 and book.labels

use XML::Simple;
use File::Basename;
use Data::Dumper;
use Cwd 'abs_path';

my $book = $ARGV[0];
my $csv_file = $ARGV[1];

my $xml_dir = "/home/bcrowell/Documents/programming/spotter/answers/";
my $xml_fragment_file = "${xml_dir}$book.labels";
my $xml_file = "${xml_dir}$book.xml";
my $m4_file = "${xml_dir}$book.m4";

my $whoami = basename($0); # http://stackoverflow.com/questions/4600192/how-to-get-the-name-of-perl-script-that-is-running

unless ($book=~/\w/ && $csv_file=~/\w/) {barf("this script requires command-line arguments; you can run it by doing make preflight")}

my $debug = 0;

sub barf {
  my $message = shift;
  print STDERR "error in $whoami\n";
  print STDERR $message,"\n";
  exit(-1);
}

my @errors = ();

sub debug {
  my $message = shift;
  if ($debug) {print STDERR "$message\n"}
}

debug("starting");

# -------- read problems.csv --------------------------------------------

if (!-e $csv_file) {
  # This script gets run by preflight, so if the book has never been compiled before in this
  # directory, problems.csv won't exist. That's OK, just exit silently.
  exit(0);
}

debug("done reading csv file $csv_file");

#   fields:
#     book = mnemonic such as lm, fund, ...
#     ch = chapter (without any leading zero)
#     num
#     name = (see note below)
#     soln = 0 or 1, boolean indicating whether the problem has a solution in the back of the book

my %csv_info = ();
my $xml_fragment = "<!-- labels output by $whoami to file $xml_fragment_file\n     labels are output for all problems, not just the ones that are actually online problems -->\n";
open(F,"<$csv_file") or barf("error opening $csv_file for input, $!");
while(my $line=<F>) {
  if ($line =~ /(.*),(.*),(.*),(.*),(.*)/) { 
    my ($csv_book,$ch,$num,$label,$solution) = ($1,$2,$3,$4,$5);
    if ($csv_book eq $book && $label ne 'deleted') {
      if (exists $csv_info{$label}) {
        push @errors,"label $label is defined more than once in $csv_file ; this means that the xml fragment in $xml_fragment_file will not work";
      }
      $xml_fragment = $xml_fragment . "<num id=\"$label\" label=\"$num\"/>\n";
      $csv_info{$label} = [$csv_book,$ch,$num,$solution];
    }
  }
}
close F;
open(F,">$xml_fragment_file") or barf("error opening $xml_fragment_file for output, $!");
print F $xml_fragment;
close F;

#======================================================================================================

my $c = "m4 -P -I $xml_dir $m4_file >$xml_file";
print STDERR "$c\n"; # qwe
-e $m4_file or barf("file $m4_file doesn't exist");
system($c)==0 or barf("error executing command $c");
print STDERR "done\n"; # qwe
