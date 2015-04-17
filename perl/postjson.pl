#!/usr/bin/perl
use strict;
use LWP::UserAgent;

my $url = "http://192.168.39.17:8080/api";
my $req = HTTP::Request->new(POST => $url);
$req->header('Content-Type' => 'application/json');
my $json = '{"message":"helloworld","chatroom":"#IT"}';
$req->content($json);

my $lwp = LWP::UserAgent->new;
my $res = $lwp->request($req);

if($res->is_success) {
   print $req->content($json);
   print $res->content;
}

else {
  print $res->status_line."\n";
}
