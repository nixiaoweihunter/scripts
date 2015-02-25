#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: chownuser.pl
#
#        USAGE: ./chownuser.pl  
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
#      CREATED: 11/03/2014 05:56:09 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;



my @array;
my %hash;

open(my $fh, "ls -l |") or die $!;
while(<$fh>){
        if(/^d.*?/){
                @array=split;
                $hash{$array[2]}=$array[8];
                                                    }
}

foreach my $item (values %hash){
            system("chown $item $item");
}
}

