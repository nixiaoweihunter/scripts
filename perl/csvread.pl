#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: csvread.pl
#
#        USAGE: ./csvread.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 08/14/2014 02:49:14 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Encode qw(from_to);
use Encode::Detect::CJK qw(detect);

open(FH,"111.txt") or die $!;
while(<FH>){
    chomp;
    my $charset = detect($_);
    from_to($_,$charset,'utf8');
    print "$_\n";
}



