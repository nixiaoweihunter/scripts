#coding: utf8
from bs4 import BeautifulSoup
import cookielib
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import pytz
import re
import smtplib
import urllib
import urllib2
from urlparse import parse_qs
from datetime import datetime, timedelta

index_url = "http://zabbix01.oa.hxshop.com/index.php"
chart_url = "http://zabbix01.oa.hxshop.com/charts.php"

image_url = "http://zabbix01.oa.hxshop.com/chart2.php"
lb38_id = 611
db01_104_id = 676

local_tz = pytz.timezone( 'Asia/Shanghai' )
email_template = '''
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<div>
<p><b>%s&nbsp;负载10.10.3.8流量</b></p>
<img src="cid:image1"/>
</div>
<div>
<p><b>%s&nbsp;网站流量</b></p>
<img src="cid:image2"/>
</div>
</body>
</html>
'''



class ZabbixHelper( object ):
    def __init__( self ):
        cj = cookielib.CookieJar()
        self.opener = urllib2.build_opener( urllib2.HTTPCookieProcessor( cj ) )
        self.chart_data = None
    def login( self ):
        req = urllib2.Request( index_url, urllib.urlencode( {
                    'autologin': 1,
                    'enter': 'Sign in',
                    'name': 'guest'
                    } ) )
        response = self.opener.open( req )
    def chart( self ):
        req = urllib2.Request( chart_url )
        response = self.opener.open( req )
        html = response.read().decode( 'utf-8' )
        exp = 'graphid=\d+&period=\d+&stime=\d+&updateProfile=1&profileIdx=web\.screens&profileIdx2=\d+'
        pattern = re.compile( exp )
        url = pattern.findall( html )[ 0 ]
        data = parse_qs( url )
        data.update( { 'period': 604800 } )
        self.chart_data = data

    def _get_image_req( self, data ):
        url = '%s?%s' % (
            image_url,
            urllib.urlencode( data ) )
        return urllib2.Request( url )
    def _update_data( self, graphid ):
        self.chart_data.update( { 'graphid': graphid,
                                   'profileIdx2': graphid } )

        
    def download_image( self, graphid ):
        self._update_data( graphid )
        req = self._get_image_req( self.chart_data )
        img = self.opener.open( req ).read()
        return img
    
    def send_email( self, img_hxshop, img_em ):
        sender = 'noreply@hxshop.com'
#        receiver = [ 'wang.xiaolong710@chinaredstar.com', 'wu.chengjiang@chinaredstar.com' ]
	receiver = [ 'ni.xiaowei@chinaredstar.com' ]
        smtp_server = 'mail.hxshop.com'
        password = 'd31xddg&Ha'


        now = datetime.now( tz = local_tz )
        t7 = now - timedelta( days = 7 )
        time_pattern = '%Y-%m-%d'
        time_period = '%s 至 %s' % ( t7.strftime( time_pattern ), now.strftime( time_pattern ) )
        
        msgRoot = MIMEMultipart('related')
        msgRoot['Subject'] = '%s监控图' % ( time_period, )
        

        msgText = MIMEText( email_template % ( time_period, time_period ), 'html', 'utf-8' )
        msgRoot.attach( msgText )

        msgImage1 = MIMEImage( img_hxshop )
        msgImage1.add_header( 'Content-ID', '<image1>' )
    
        msgImage2 = MIMEImage( img_em )
        msgImage2.add_header( 'Content-ID', '<image2>' )

        msgRoot.attach( msgImage1 )
        msgRoot.attach( msgImage2 )

        smtp = smtplib.SMTP()
        smtp.connect( smtp_server )
        smtp.login( sender, password )
        smtp.sendmail( sender, receiver, msgRoot.as_string() )
        smtp.quit()
        

    def work( self ):
       self.login()
       self.chart()
       img1 = self.download_image( lb38_id )
       img2 = self.download_image( db01_104_id )
       self.send_email( img1, img2 )
        


if '__main__' == __name__:
    h = ZabbixHelper()
    h.work()
