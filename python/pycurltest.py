#!/usr/bin/python
# coding: UTF-8
import StringIO,pycurl,sys,os,time

class idctest:
    def __init__(self):
        self.contents = ''
    def body_callback(self,buf):
        self.contents = self.contents + buf

def test_gzip(input_url):
    t = idctest()
    #gzip_test = file("gzip_test.txt", 'w')
    c = pycurl.Curl()
    c.setopt(pycurl.WRITEFUNCTION,t.body_callback)
    c.setopt(pycurl.ENCODING, 'gzip')
    c.setopt(pycurl.URL,input_url)
    c.setopt(pycurl.MAXREDIRS, 5)
    c.perform()

    http_code = c.getinfo(pycurl.HTTP_CODE)
    dns_resolve = c.getinfo(pycurl.NAMELOOKUP_TIME)
    http_conn_time =  c.getinfo(pycurl.CONNECT_TIME)
    http_pre_trans = c.getinfo(pycurl.PRETRANSFER_TIME)
    http_start_trans = c.getinfo(pycurl.STARTTRANSFER_TIME)
    http_total_time = c.getinfo(pycurl.TOTAL_TIME)
    http_size_download = c.getinfo(pycurl.SIZE_DOWNLOAD)
    http_header_size = c.getinfo(pycurl.HEADER_SIZE)
    http_speed_downlaod = c.getinfo(pycurl.SPEED_DOWNLOAD)

    print 'HTTP CODE %d' %http_code
    print 'DNS resolved %.2f ms' %(dns_resolve*1000)
    print 'http_conn_time %.2f ms' %(http_conn_time*1000)
    print 'http_pre_trans %.2f ms' %(http_pre_trans*1000)
    print "http_start_trans %.2f ms" %(http_start_trans*1000)
    print "http_totle_time %.2f ms" %(http_total_time*1000)
    print "http_size_download %d bytes/s" %http_size_download
    print "http_header_size %d bytes/s" %http_header_size
    print "http_speed_download %d k/s" %(http_speed_downlaod/1024)


if __name__ == '__main__':
    input_url = sys.argv[1]
    test_gzip(input_url)
