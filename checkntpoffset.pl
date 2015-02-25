#!/usr/bin/perl
use strict;

my $offset=100;
my $command="/usr/sbin/ntpq -p";

open( my $fh, "$command |") or die "$!";
    while ( <$fh> ) {
              my @array=split;
                 if($array[8] =~ /\d+/){
                     if($array[8]>$offset){
                         print "1";
                     }
                     else{
                         print "0";
                     }
                 }
    }
