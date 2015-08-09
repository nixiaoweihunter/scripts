#!/usr/bin/env perl
use utf8;  
use Encode;  
use URI::Escape;  
   
   
#从unicode得到utf8编码  
$str = '%u6536';  
$str =~ s/\%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;  
$str = encode( "utf8", $str );  
print uc unpack( "H*", $str ),"\n";  
   
# 从unicode得到gb2312编码  
$str = '%u6536';  
$str =~ s/\%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;  
$str = encode( "gb2312", $str );  
print uc unpack( "H*", $str ),"\n";  
   
# 从中文得到utf8编码
my $str = '中文';  
print uri_escape_utf8($str),"\n";
 
 
# 从utf8编码得到中文  
my $utf8_str = uri_escape_utf8 ("中文");  
print uri_unescape($utf8_str),"\n";  
 
# 从中文得到perl unicode  
utf8::decode($str);  
@chars = split //, $str;  
foreach (@chars) {  
    printf "%x ", ord($_),"\n";  
}
 
 
# 从中文得到标准unicode
$str = '中文';
map { print "\\u", sprintf( "%x", $_ ) ,"\n"} unpack( "U*", $str );  
   
 
# 从标准unicode得到中文  
$str = '%u4e2d%u6587';  
$str =~ s/\%u([0-9a-fA-F]{4})/pack("U",hex($1))/eg;  
$str = encode( "utf8", $str );  
print $str,"\n";  
   
# 从perl unicode得到中文  
my $unicode = "\x{4e2d}\x{6587}";  
print encode( "utf8", $unicode );

