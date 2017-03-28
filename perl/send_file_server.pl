#!/usr/bin/perl
#
#####################
## SEND FILE SERVER #
#####################
#
use IO::Socket ;

my $port = $ARGV[0] || 6123 ;
my $save_dir = './files' ;
#        
#        #############
#        # START SRV #
#        #############
#
if (! -d $save_dir) {
    mkdir($save_dir,0755) ;
    print "Save directory created: $save_dir\n" ;
}
            
my $server = IO::Socket::INET->new(
    Listen => 5,
    LocalAddr => 'localhost',
    LocalPort => $port ,
    Proto     => 'tcp'
) or die "Can't create server socket: $!";
                                          
print "Server opened: localhost:$port\nWaiting clients...\n\n" ;
                                              
while( my $client = $server->accept ){
    print "\nNew client!\n";
    my ($buffer,%data,$data_content);
    my $buffer_size = 1;
                                                                    
    while( sysread($client, $buffer , $buffer_size) ) {
        if    ($data{filename} !~ /#:#$/) { $data{filename} .= $buffer ;}     
        elsif ($data{filesize} !~ /_$/) { $data{filesize} .= $buffer ;}
                                                                                                elsif ( length($data_content) < $data{filesize}) {
                                                                                
        if ($data{filesave} eq '') {
                                                                                                $data{filesave} = "$save_dir/$data{filename}" ;
                                                                                                $data{filesave} =~ s/#:#$// ;
                                                                                                $buffer_size = 1024*10 ;
                                                                                                if (-e $data{filesave}) { unlink ($data{filesave}) ;}
                                                                                                print "Saving: $data{filesave} ($data{filesize}bytes)\n" ;
                                                                                             }
                                
    open (FILENEW,">>$data{filesave}") ; binmode(FILENEW) ;
                                                                                            print FILENEW $buffer ;
                                                                                            close (FILENEW) ;
                                                                                            print "." ;        
                                                                                             }
                                                                                            else { last ;}
                                                                                             }                                                
                                                                                             print "OK\n\n" ;
                                                                                              }                                                                                                                                           
######                                                                                  ## END ##
########
