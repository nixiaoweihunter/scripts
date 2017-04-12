#!/usr/bin/python
# -*- coding: utf-8 -*-
import urllib2
import json

surl='http://120.26.72.51:15672/api/overview'


passman = urllib2.HTTPPasswordMgrWithDefaultRealm() #创建域验证对象    
passman.add_password(None, surl, "admin", "ZmVhNDUyZjA1ZGI2") #设置域地址，用户名及密码    
auth_handler = urllib2.HTTPBasicAuthHandler(passman) #生成处理与远程主机的身份验证的处理程序    
opener = urllib2.build_opener(auth_handler) #返回一个openerDirector实例    
urllib2.install_opener(opener) #安装一个openerDirector实例作为默认的开启者。    
response = urllib2.urlopen(surl) #打开URL链接，返回Response对象    
resContent = response.read() 
print resContent





