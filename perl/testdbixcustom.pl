#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 04/11/2015 08:27:03 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use DBIx::Custom;
use Data::Dumper;

my $dbi = DBIx::Custom->connect(
    dsn => "dbi:mysql:database=hunter:localhost:3306",
    user => "root",
    password => "hunter1983907",
    option => {
        mysql_enable_utf8 => 1
    }
);

my $result = $dbi->execute(
    "select title from q_query where id = :id",
    {
        id => '116',
    }
);

my $row = $result->one;

print $row->{title};
