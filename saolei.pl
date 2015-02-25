#!/usr/bin/perl
use strict;
use Term::ANSIColor;
use Term::Screen;

my $term = Term::Screen->new;

$term->clrscr();
$term->noecho();

my ($X,$Y,$MCount,$FCount,$SCount);
my @array;
my ($cleared,$hits) = (0,0,0);
&gameInit;
&mapArray;
&drawMap;

my $col = 1;
my $row = 1;
while(my $key = $term->getch()){
    my $num;
    $key =~ /^d/i and $col < $X*2-1 and $col += 2,$term->at($row,$col);
    $key =~ /^a/i and $col > 2 and $col -= 2,$term->at($row,$col);
    $key =~ /^w/i and $row > 1 and $term->at(--$row,$col);
    $key =~ /^s/i and $row < $Y and $term->at(++$row,$col);
    $key =~ /^t/i and &dig($row,$col);
    $key =~ /^m/i and &mark($row,$col);
    $key =~ /^c/i and &clear($row,$col);
    $key =~ /^q/i and $term->clrscr,last;
}

sub gameInit{
    
    my $key;
    my ($rows,$cols) = (24,80);
    my ($posX,$posY) = (6,24);        
    ###reszieing window alwarys failed to work
        $term->resize($rows,$cols);
        $term->at($posX,$posY);
        print colored("++++++++++++++++++++++++++++++",'yellow'),"\n";
        $term->at(++$posX,$posY);
        print colored("            1)easy            ",'yellow'),"\n";
        $term->at(++$posX,$posY);
        print colored("            2)normal          ",'yellow'),"\n";
        $term->at(++$posX,$posY);
        print colored("            3)hard            ",'yellow'),"\n";
        $term->at(++$posX,$posY);
        print colored("            4)exit            ",'yellow'),"\n";
        $term->at(++$posX,$posY);
        print colored("++++++++++++++++++++++++++++++",'yellow'),"\n";
        $term->at(++$posX,$posY);
        print colored("hit a key...",'yellow');
        while($key = $term->getch()){
                   $key =~ /^1$/ and $X=10,$Y=10,$MCount=10,$FCount=10,$SCount=100,last;
                   $key =~ /^2$/ and $X=20,$Y=14,$MCount=18,$FCount=28,$SCount=280,last;
                   $key =~ /^3$/ and $X=36,$Y=18,$MCount=65,$FCount=65,$SCount=648,last;
                   $key =~ /^4$/ and exit 0;
         }
}


sub mapArray{
    @array = map { [ map { 'S' } 1..$X ] } 1..$Y;
    my $count = 0;
    while(1){
        my ($mx,$my) = (int(rand($X)),int(rand($Y)));
        #2;D\SC&& why?
        $array[$mx][$my] =~ /^[^M]/i and $array[$mx][$my] = 'M', $count++;
        last if($count == $MCount);
    } 
}


sub drawMap{
    my ($posX,$posY) = (1,1);
    $term->clrscr();
    print map {"--"} 1..$X;
    my $delimiter = colored("|",'green');
    my $oox = colored("X",'blue bold');
    my $str = join($delimiter,map {$oox} 1..$X);
    $term->at($posX,$posY);
    foreach(1..$Y){
        print $str;
        $term->at(++$posX,$posY);
    }
    print map {"--"} 1..$X;
    $term->at(1,$posY);
}

sub dig{
    my ($row,$col) = @_;
    my ($x,$y) = ($row-1,int($col/2));

    if($array[$x][$y] =~ /^m/i){
        &gameOver($row,$col);
    }
    
    my $num = &getNum($x,$y);
    $term->puts($num);
    $term->at($row,$col);
    
    $array[$row-1][int($col/2)] =~ /^m/i or ++$cleared;
    (my $c = $hits + $cleared) == $SCount and &gameExit;
}

sub mark{
    my ($row,$col) = @_;
    my $mark = colored("m",'red bold');
    $term->puts($mark);
    $term->at($row,$col);

    $array[$row-1][int($col/2)] =~ /^m/i and ++$hits;
    (my $c = $hits + $cleared) == $SCount and &gameExit;
}

sub clear{
    my ($rows,$col) = @_;
    my $clear = colored('X','blue bold');
    $term->puts($clear);
    $term->at($row,$col);
    
    if($array[$row-1][int($col/2)] =~ /^m/i){
        --$hits;
    }else{
        --$cleared;
    }
}

sub getNum{
    my $num = 0;
    my ($x,$y) = @_;

    ($x-1>-1 and $y-1>-1) and $array[$x-1][$y-1] =~ /^m/i and ++$num;
    $x-1 >-1 and $array[$x-1][$y] =~ /^m/i and ++$num;
    ($x-1>-1 and $y+1<$Y) and $array[$x-1][$y+1] =~ /^m/i and ++$num;
    $y-1 >-1 and $array[$x][$y-1] =~ /^m/i and ++$num;
    $y+1<$Y and $array[$x][$y+1] =~ /^m/i and ++$num;
    ($x+1<$X and $y-1>-1) and $array[$x+1][$y-1] =~ /^m/i and ++$num;
    $x+1<$X and $array[$x+1][$y] =~ /^m/i and ++$num;
    ($x+1<$X and $y+1<$Y) and $array[$x+1][$y+1] =~ /^m/i and ++$num;

    $num = $num==0?" ":$num;
    return $num;
}

sub gameOver{
    my ($row,$col) = @_;
    &plotMap($row,$col);
    print colored('Game over...("q" to quit and "n" to  start a new game)','red');
    my $key = $term->getch();
    $key =~ /^q/i and $term->clrscr(),exit 0;
    $key =~ /^n/i and exec 'perl',$0;
}

sub plotMap{
    my ($row,$col) = @_;
    my ($posX,$posY) = (1,1);
    my $mark = colored('M','blue bold');
    my $delimiter = colored('|','green');
    my $missed = colored('X','red bold');
    
    $term->clrscr();
    print map {"--"} 1..$X;
    $term->at($posX,$posY);
    foreach(1..$Y){
        print join ($delimiter, map{/^s/i?" ":$mark} @{$array[$_-1]});
        $term->at(++$posX,$posY);
    }
    print map {"--"} 1..$X;
    $term->at($row,$col);
    $term->puts($missed);
    $term->at(++$posX,$posY);
    
}

sub gameExit{
    $term->at($X+2,1);
    print colored ('success....','yellow bold');
    exit 0;
}
