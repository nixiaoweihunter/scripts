#!/usr/bin/perl
use strict;
use AnyEvent;

my $dns;
my $querytime;
my $command = "dig \@192.168.100.130 www.ctrip.com";

my $cv = AnyEvent->condvar;

my $w = AnyEvent->timer (after => 3,
                         interval => 1,
                         cb => sub {
                             open(my $fh, "$command |") or die $!;
                               while(<$fh>) {
                                 if(/.*?A\s+(\d+(?:\.\d+){3})/){
                                     $dns=$1;
                                     print "A Record is: $dns"."\n";
                                 }
      
                                 if(/.*?Query time:\s+(\d+)\s+msec/){
                                     $querytime=$1;
                                     print "Query time is: $querytime msec"."\n";
                                 } 
                               }
                    }
                         
);

$cv->recv;


