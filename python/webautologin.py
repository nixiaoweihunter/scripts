#!/root/python27/bin/python
# -*- coding: utf-8 -*-
import cookielib
import urllib
import urllib2

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
index_url = ""

req = urllib2.Request( index_url, urllib.urlencode( {
                    'autologin': 1,
                    'enter': 'Sign in',
                    'name': '',
		    'password': ''
                    } ) )

response = opener.open( req )
html = response.read().decode( 'utf-8' )
print html




