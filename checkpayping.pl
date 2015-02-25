#!/usr/bin/perl
use strict;
use warnings;
use Net::Ping;
use Net::IP;
use Parallel::ForkManager;

my $p = Net::Ping->new();
my $ip1 = new Net::IP('192.168.139.1 - 192.168.139.10') or die $!;
my $ip2 = new Net::IP('192.168.139.21 - 192.168.139.250') or die $!;
my @iparray;
my $counter=0;

do {
   push(@iparray,$ip1->ip()); 
} while (++$ip1);

do {
   push(@iparray,$ip2->ip());
} while (++$ip2);


my $pm = Parallel::ForkManager->new(30);

foreach my $i (@iparray) {
  $pm->start and next;
  open(FH,">>payping") or die $!;
#  my $p = Net::Ping->new();
  print FH "$i is alive.\n" if $p->ping($i);
  $p->close();	

  $pm->finish;
}
$pm->wait_all_children;


open(FH,"<payping") or die $!;
while(<FH>){
	if(/alive/){
		$counter++;
	}
}
print int($counter*100/240);
print "%\n";

no strict 'subs';
if( -e "payping"){
unlink "payping"
}
