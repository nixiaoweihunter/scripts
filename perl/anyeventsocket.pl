#!/usr/bin/perl
use strict;
use AnyEvent;
use AnyEvent::Socket;

my $cv = AnyEvent->condvar;

tcp_server undef, 8888, sub {
   my ($fh,$host,$port) = @_;
   syswrite $fh,"The internet is full, $host:$port. Go away!\015\012";
};

$cv->recv;
