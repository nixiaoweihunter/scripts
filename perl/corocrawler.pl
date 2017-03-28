#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: corocrawler.pl
#
#        USAGE: ./corocrawler.pl  
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
#      CREATED: 10/10/2014 05:02:11 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Coro;
use AnyEvent::HTTP;
use BerkeleyDB;


# 参数设置
 my $limit = 10; # 异步抓取数量
#
#
# # 初始化数据库
 my $filename = "URLs.db";
 tie my %url, 'BerkeleyDB::Btree',
     -Filename => $filename,
         -Flags    => DB_CREATE
             or die "Cannot open $filename: $! $BerkeleyDB::Error\n";

             $filename = "Queue.db";
             tie my @queue, 'BerkeleyDB::Recno',
                 -Filename => $filename,
                     -Flags    => DB_CREATE
                         or die "Cannot open $filename: $! $BerkeleyDB::Error\n";


#                         # 初始化进度条
                         my $total;
                         my $done;
                         if (exists $ARGV[0]){
    push @queue, $ARGV[0];
        $url{$ARGV[0]} = 1;
            $total         = 1;
                $done          = 0;
}else {exit 0};

# 间隔一段时间报一次进度
 $| = 1;
 my $progress = AnyEvent->timer (
     after => 0,
         interval => 1,
             cb    => sub {
        print "*当前进度：$done/$total(完成/总量)\r";
            },
            );


# 异步HTTP请求
 my $sem = new Coro::Semaphore $limit;
 my $sig = new Coro::Signal;
 $Coro::POOL_SIZE            = $limit;
#
while (1){
        if(my $url = pop @queue){     # 列队请求
                    $sem->down;
                    async_pool {
                            my $url = shift;
                            http_get $url, Coro::rouse_cb;

                            my @res = Coro::rouse_wait;
                            my $urls = &URL($url,\$res[0]);

                            foreach (@$urls){
                                    if (not exists $url{$_}){
                                            push @queue, $_;
                                            $url{$_} = 1;
                                           $total++;                                                                                                                                                                                                      }         
                            }

                              $done++;
                              $sem->up;
                              $sig->send;
                      } $url;
                   }elsif($sem->count < $limit){ # 等待剩余进程返回
                           $sig->wait;
                   }else{                        # 全部剩余进程返回，结束循环
                           last;
        }
}

undef $progress;
print "\n抓取完成：完成$done/总量$total\n";

# 关闭数据库连接
 untie %url;
 untie @queue;

sub URL{
        my $base = shift;
            my $HTML = shift;
                #scheme://domain:port/path?query_string#fragment_id
            my $sdp;
            if ($base =~ m#^(\w+://[^/]+)/?#){
                $sdp = $1;
            }
            my $sdpp;
            if ($base =~ m#^(\w+://.+)/[^/]?#){
                $sdpp = $1 . '/';
            }else {$sdpp = $sdp . '/'}

            my @urls;
            while ($HTML =~ /<a\b([^>]+)>/ig){
                if ($1 =~ /\bhref\s*=\s*(?:"([^"]*)"|'([^']*)'|([^'">\s]+))/i){
                    my $url = $+;
                    next if (
                        $url =~ /^#/             ||
                        $url =~ /^javascript:;/i ||                                                                                $url =~ /^mailto:/i);

                        if ($url =~ m#^http://#i && $url =~ /$sdp/){
                            push @urls, $url;
                      }elsif ($url =~ m#^/[^/]#){                                                                                      push @urls, $sdp . $url;
                      }elsif ($url =~ /^\.[^.]/){
                            push @urls, $sdpp . substr $url, 2;                                                                  }elsif ($url =~ /^\w/){
                            push @urls, $sdpp . $url;                                                                            }#else处理异常
                    }
                }

    return \@urls;
}
