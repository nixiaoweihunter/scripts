#!/usr/bin/perl
use strict;
use Search::Elasticsearch;
use Data::Dumper;

my $e = Search::Elasticsearch->new(
	nodes => '192.168.39.7:9200',
);

my $result = $e->indices->delete(index=>'articles');

print Dumper($result);
				

