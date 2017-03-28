#!/usr/bin/perl
use strict;
use LWP::UserAgent;

my $login_url='http://192.168.39.20:8000/login';


my %login_form=(
	username=>'nixiaowei',
	password=>'123456',
);


my $ie = LWP::UserAgent->new();

my $res=$ie->post($login_url, \%login_form);


my %hash;
foreach ( split(/\n/,$res->as_string) ) {
        my ($key,$value) = split(/: /,$_);
         $hash{$key} = $value;
}
if ( $hash{'Location'} ) {
        print "login successful!\n";
}
else {
        print "login error!\n";
}
