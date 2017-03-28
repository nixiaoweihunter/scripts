# -*- coding:utf8 -*-
#/usr/bin/python
import socket,time,thread
socket.setdefaulttimeout(3)
 
def socket_port(ip,port):
	"""
	input ip and port
	"""
	try:
		if port >= 65535:
			print u'scan port finish.'
		s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
		result=s.connect_ex((ip,port))
		if result==0:
			lock.acquire()
			print ip,u':',port,u'port open'
			lock.release()
		s.close()
	except:
		print u'port scan abnormal'

def ip_scan(ip):
	"""
	input ip,scan the ip's port from 0 to 65534
	"""
	try:
		print u'start scanning %s' % ip
		start_time=time.time()
		for i in range(0,65534):
			thread.start_new_thread(socket_port,(ip,int(i)))
		print u'scan port finish,total used:%.2f' %(time.time()-start_time)
		raw_input("Press Enter to Exit")
	except:
		print u'scan ip error'

if __name__=='__main__':
	url=raw_input('Input the ip you want to scan:\n')
	lock=thread.allocate_lock()
	ip_scan(url)

