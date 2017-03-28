#!/usr/bin/perl
use strict;
use LWP::UserAgent;

my $url="http://$ARGV[0]";
my $ua = LWP::UserAgent->new;

$ua->timeout(10);
$ua->proxy(['http'],'http://proxylogin.cn1.global.ctrip.com:8080/');

my $response = $ua->get($url);

print $response->code."\n";
