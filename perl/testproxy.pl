#!/usr/bin/perl
use strict;
use LWP::UserAgent;

#my $url="http://www.baidu.com";
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->proxy(['http'],'http://proxylogin.cn1.global.ctrip.com:8080/');

my $response = $ua->get('http://www.baidu.c');

# if ($response->is_success) {
#     print $response->content;
# }
# else {
#     die $response->status_line;
# }

#print $response->status_line."\n";
print $response->code."\n";


