#!/usr/bin/perl
use strict;
use Term::Screen;

my $term = Term::Screen->new;

$term->clrscr();

while(my $key = $term->getch()) {
	print $key;
}
