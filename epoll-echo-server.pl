#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: epoll-echo-server.pl
#
#        USAGE: ./epoll-echo-server.pl  
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
#      CREATED: 09/11/2014 09:28:06 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Getopt::Long;
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use IO::Socket::INET;
use IO::Epoll;
use Fcntl;
use POSIX qw(:errno_h);

my $concurrent = 10;
my $port = 9010;

GetOptions(
	'concurrent=s'=>\$concurrent,
	'port=i' => \$port,
);

print "$0: http://localhost:$port/\n";
print "concurrency:$concurrent\n";

my $epfd = epoll_create(10);

my $listener = IO::Socket::INET->new(
	LocalHost => '0.0.0.0',
	LocalPort => $port,
	Listen => 10,
	ReuseAddr => 1,
) or die $!;

my @Sock_Holder;
my $listener_fd = fileno($listener);

epoll_ctl($epfd,EPOLL_CTL_ADD,$listener_fd,EPOLLIN) >= 0 || die "epoll_ctl:$!\n";

sub with_sysread{
	my($ev) = @_;
	open my $sock,"+<&=".$ev->[0] or die "fdopen:$!";

	my $buf = "";
	my $r = sysread $sock,$buf,24;
	
	if($r){
		syswrite $sock,$buf,$r;
	}else{
		if(!defined $r && ($! == EINTR || $! == EAGAIN)){
			next;
		}
		epoll_ctl($epfd,EPOLL_CTL_DEL,$ev->[0],0) >= 0 || die "epoll_ctl:$!\n";
		$Sock_Holder[$ev->[0]] = undef;
		close $sock;
	}
}

sub with_perlio{
	my($ev) = @_;
	open my $sock,"+<&=".$ev->[0] or die "fdopen:$!";

	my $buf = <$sock>;

	if ($buf) {
		print $sock $buf;
	}else {
		epoll_ctl($epfd,EPOLL_CTL_DEL,$ev->[0],0) >= 0 || die "epoll_ctl:$!\n";
		$Sock_Holder[$ev->[0]] = undef;
		close $sock;
	}	
}

if($ENV{USE_PERLIO}) {
	print "use perl io\n";
	*process_connection = \&with_perlio;
}else{
	print "use sysread,syswrite\n";
	*process_connection = \&with_sysread;
}

while(1) {
	my $events = epoll_wait($epfd,$concurrent,-1);

	for my $ev(@$events) {
		if($ev->[0] == $listener_fd){
			my $sock = $listener->accept;
		 	my $sock_fd = fileno($sock);
			$Sock_Holder[$sock_fd] = $sock;

		 	setsockopt($sock,IPPROTO_TCP,TCP_NODELAY,1);
		 	my $flags = fcntl($sock,F_GETFL,0) or die "fcntl GET_FL:$!";
		 	fcntl($sock,F_SETFL,$flags|O_NONBLOCK) or die "fcntl SET_FL:$!";

		  	epoll_ctl($epfd,EPOLL_CTL_ADD,$sock_fd,EPOLLIN) >= 0 || die "epoll_ctl:$!\n";
	         }else{
			process_connection($ev);
		 }
	}
}
