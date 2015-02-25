#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: selectsocket.pl
#
#        USAGE: ./selectsocket.pl  
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
#      CREATED: 08/06/2014 09:54:59 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use IO::Socket;
use IO::Select;
use Parallel::Prefork;

$|++;

my $s;
my $read_set;

$s = IO::Socket::INET->new(
        LocalAddr => '0.0.0.0',
        LocalPort => 8888,
        Listen => 5,
        Proto => 'tcp',
        ReuseAddr => 1,
) or die $@;

my $pm=Parallel::Prefork->new(
{
    max_workers => 5,
    trap_signals => {
    TERM => 'TERM',
    HUP => 'TERM',
    USR1 => undef,
    }
}
);


$read_set = IO::Select->new();
$read_set->add($s);


while ($pm->signal_received ne 'TERM'){

$pm->start(
sub {
    
while(1) {
    my($rh_set) = IO::Select->select($read_set,undef,undef,undef);
    foreach my $rh (@$rh_set) {
        if($rh == $s){
            my $ns = $rh->accept();
            $read_set->add($ns);
        } 
        else{
            my $buf = undef;
            if(sysread($rh,$buf,32)){
	    	if($buf =~ /exit/ig){
			$read_set->remove($rh);
			$rh->close;
		}
		else{
                	print $rh->fileno," ",$buf," ";    
		}
            }
            else{
                print "no more data,close socket".$rh->fileno."\n";
                $read_set->remove($rh);
                $rh->close;
            }
        }
    }
}

});
}
$pm->wait_all_children();
