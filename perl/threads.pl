#!/usr/bin/env perl
use strict;
use warnings;
use threads;
use threads::shared;
use Thread;
use Thread::Queue;
use POSIX;

my %chat_ans_map = (
	"Hello" => "Hithere",
	"Who" => "I'm a thread.My name is",
	"old" => "Not as old as yesterday!",
	"slaved" => "If you compete with a slave,you'll become one",
	"lonely" => "Lonely is my middle name and I can't shake it off!",
	"sorry" => "That's alright! You are a thread too,aren't you? I'm not alone!",
	"hehe" => "hehe:D",
	"Where" => "A place set with oak and cedar tree,somewhere between nowhere and goodbye",
	"Byebye" => "Take care!"
);

my %chat_map = (
	"0" => "Hello",
	"1" => "Who is this speaking ?",
	"2" => "Wow.Same here! How old are you ?",
	"3" => "How do you like being slaved to do things incessantly?",
	"4" => "I'm sorry to hear that!",
	"5" => "Indeed! Are you feeling lonely out there running 24/7",
	"6" => "hehe",
	"7" => "Where are you running now?",
	"8" => "Hmmm...Byebye",
	"9" => "END",
);

my $chat_ask_queue =Thread::Queue->new();
my $chat_ask = threads->new(\&chat_ask,"Thread_A",Thread->self());
my $chat_ans = threads->new(\&chat_ans,"Thread_B",Thread->self());

$chat_ask->join();
$chat_ans->join();


sub chat_ask {
	my ($name,$selfid) =@_;
	my $index = 0;
	while(1) {
		sleep 5;
		last if ($chat_map{$index} =~ /END/);
		my $content = getTime()." ".$name.": ".$chat_map{$index};

		$chat_ask_queue->enqueue($content);
		$index++;
		print "$content\n";		
	}
}

sub chat_ans {
	my ($name,$selfid) = @_;

	while(my $feedback = $chat_ask_queue->dequeue()) {
		sleep 2;
		my $answer = match_ans($feedback);
		my $content;
		$content = getTime()." ".$name.": ".$answer;
		$content = $content.$selfid if ($feedback =~ /Who/);
		print "$content\n";
		last if ($feedback =~ /Byebye/);
	}
}

sub match_ans {
	my $incoming_msg = $_[0];
	foreach my $tmp (keys %chat_ans_map){
		if($incoming_msg =~ /$tmp/){
			return $chat_ans_map{$tmp};
		}
	}
}

=cut
sub exit_all {
	my @thread_list = threads->list();
	foreach my $tmp (@thread_list) {
		$tmp->join();
	}
}

=cut
sub getTime {
	my $timestamp=time;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timestamp);
	my $m = $mon+1;
	my $ret = $m."-".$mday." ".$hour.":".$min.":".$sec;
	return $ret;
}
