#!/usr/bin/perl
use strict;

my $dns;
my $ip=$ARGV[0];
my $command = "dig \@$ip Server.sh.ctriptravel.com";

open(my $fh, "$command |") or die $!;
while(<$fh>) {
      if(/.*?A\s+(\d+(?:\.\d+){3})/){
         $dns=$1;
         print "$dns"."\n";
      }
      
}
