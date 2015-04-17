#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: epollsocket.pl
#
#        USAGE: ./epollsocket.pl  
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
#      CREATED: 02/28/2015 02:58:13 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use IO::Socket;
use IO::Epoll;
use Carp;
use Fcntl;
use POSIX qw(:errno_h);


my $sock;
my $epfd;
my @sock_holder;

$sock = IO::Socket::INET->new(
    LocalAddr => '0.0.0.0',
    LocalPort => 80,
    Listen => 5,
    Proto => 'tcp',
    ReuseAddr => 1,
) or carp "estable socket error...";

$epfd = epoll_create(10);
my $listener_fd = fileno($sock);

epoll_ctl($epfd,EPOLL_CTL_ADD,$listener_fd,EPOLLIN) >= 0 or carp "epoll_ctl error...";


while(1){
    my $events = epoll_wait($epfd,10,-1);

    for my $ev(@$events) {
        if($ev->[0]==$listener_fd){
            my $ns = $sock->accept();
            my $ns_fd = fileno($ns);
            $sock_holder[$ns_fd] = $ns;
#            setsockopt($sock,IPPROTO_TCP,TCP_NODELAY,1);
            my $flags = fcntl($ns,F_GETFL,0) or carp "fcntl GET_FL error...";
            fcntl($ns,F_SETFL,$flags|O_NONBLOCK) or carp "fcntl SET_FL error...";

            epoll_ctl($epfd,EPOLL_CTL_ADD,$ns_fd,EPOLLIN) >= 0 or carp "epoll_ctl...";
        }
        else{
        #process_connections
	#   with_perlio($ev);
	    with_sysread($ev);
	    }
    }
}


sub with_perlio{
	my($ev) = @_;
	open my $s,"+<&=".$ev->[0] or die "fdopen:$!";

	my $buf = <$s>;

	if ($buf) {
		print "$buf";
	}else {
		epoll_ctl($epfd,EPOLL_CTL_DEL,$ev->[0],0) >= 0 || die "epoll_ctl:$!\n";
		$sock_holder[$ev->[0]] = undef;
		close $s;
	}	
}


	
sub with_sysread{
	my($ev) = @_;
	open my $s,"+<&=".$ev->[0] or die "fdopen:$!";

	my $buf = "";
	my $r = sysread $s,$buf,24;
	
	if($r){
	#	syswrite $s,$buf,$r;
		print "$buf";
    #    print $s "hello";
	}else{
		if(!defined $r && ($! == EINTR || $! == EAGAIN)){
			next;
		}
		epoll_ctl($epfd,EPOLL_CTL_DEL,$ev->[0],0) >= 0 || die "epoll_ctl:$!\n";
		$sock_holder[$ev->[0]] = undef;
		close $s;
	}
}
