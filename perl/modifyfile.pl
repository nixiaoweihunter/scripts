#!/usr/bin/perl
use strict;

@ARGV=qw 'test.txt';
$^I='';
while(<>){
   s/world/hunter/g;
   print;
}
