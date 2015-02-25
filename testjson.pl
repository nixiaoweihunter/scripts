#!/usr/bin/perl
use strict;
use JSON;
use Data::Dumper;

print "test json data...\n";

my $json = new JSON;

my $js;

while(<DATA>){
  $js.= $_;
}

print $js;

#my $obj = $json->decode($js);
#printf Dumper($obj)."\n";

#for my $item(@{$obj->{'pwd'}}){
#   print $item->{'g1'}."\n";
#}


__DATA__
{
"un":"chengjun",
"pwd":[{
   "g1":"g1value",
   "g2":"g2value"
},{
     "g1":"g1111value",
   "g2":"g2222value"
}
]
}
