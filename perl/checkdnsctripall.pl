#!/usr/bin/perl
use strict;

my $command;
my $dnsip;
my $dnsname="Server.sh.ctriptravel.com";
#my $dnsname="zonetest.sh.ctripcorp.com";
#my $dnsname="Webresint.sh.ctriptravel.com";

my @dnsarray=<DATA>;

foreach my $ip (@dnsarray){
   chomp $ip;
   $command = "dig \@$ip $dnsname";

   open(my $fh, "$command |") or die $!;
        while(<$fh>) {
             if(/.*?A\s+(\d+(?:\.\d+){3})/){
                $dnsip=$1;
                print "$ip is $dnsip"."\n";
              }      
        }
}

__DATA__
192.168.102.31
192.168.102.32
192.168.102.20
192.168.102.21
192.168.102.22
192.168.102.24
192.168.102.25
172.17.1.194
172.17.1.6
172.17.1.67
172.17.1.7
172.18.0.51
172.18.0.52
172.18.16.51
172.18.16.52
172.19.0.41
172.19.0.42
172.28.102.26
172.28.102.20
172.28.102.21
172.28.102.86
172.28.102.87
192.168.100.80
192.168.100.130
172.28.100.10
172.28.100.11
10.8.65.1
10.8.65.2
