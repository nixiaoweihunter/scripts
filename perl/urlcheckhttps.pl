#!/usr/bin/perl
use strict;
use LWP::UserAgent;

my $url="https://$ARGV[0]";
#my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0});
my $ua = LWP::UserAgent->new();
my $res = $ua->get($url);

print $res->content."\n";

