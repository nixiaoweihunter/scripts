#!/usr/bin/perl
use strict;

my $data;

while(<DATA>){
    $data .= $_;
}

$data =~ /\{test\}//sg;

print $data;


__DATA__
{
test
}
