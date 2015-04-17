#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: proxy.pl
#
#        USAGE: ./proxy.pl  
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
#      CREATED: 08/07/2014 02:06:42 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Net::Proxy;

my $proxy = Net::Proxy->new(
    {
        in => { type => 'tcp', host=> '0.0.0.0', port => '6789'},
        out => { type => 'tcp', host => 'localhost', port => '80'},
    }
);
$proxy->register();

Net::Proxy->mainloop();
