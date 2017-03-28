#!/usr/bin/env perl
use strict;
use warnings;

my $fastdfs_upload_filename="$ARGV[0]";
my $fastdfs_action="upload";
my $fastdfs_command="/usr/bin/fdfs_test";
my $fastdfs_client_conf="/etc/fdfs/client.conf";


sub fastdfs_uploadfile {
	my $filename = shift;
	my $stdout = `$fastdfs_command $fastdfs_client_conf $fastdfs_action $filename`;
	print $stdout;
};

fastdfs_uploadfile($fastdfs_upload_filename);

