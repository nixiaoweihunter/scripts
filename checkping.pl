#!/usr/bin/perl
#2013/10/29-14:52:24
use strict;

my $ms;
my $command="ping $ARGV[0]";

open( my $fh, "$command |") or die "$!";
    while ( <$fh> ) {
        if(/.*?=\s(\d+)ms$/){
             $ms=$1;
             print $ms."\n";     
         }    
     }
     if($ms<0 || !defined($ms)){
        print "9999\n";  
     }