#!/root/python27/bin/python
# -*- coding: utf-8 -*-
from email.mime.text import MIMEText
from email import encoders
from email.header import Header
from email.utils import parseaddr,formataddr
import smtplib


smtp_server = ""
from_addr = ""
passwd = ""
to_addr = ""

def _format_addr(s):
	name, addr = parseaddr(s)
        return formataddr((Header(name,'utf-8').encode(),addr.encode('utf-8') if isinstance(addr,unicode) else addr))

msg = MIMEText('This is a test mail...','plain','utf-8')
msg['From'] = _format_addr(u'倪晓伟<%s>' % from_addr)
msg['To'] = _format_addr(u'倪晓伟<%s>' % to_addr)
msg['subject'] = Header(u'这是一个测试邮件。。。','utf-8').encode()


server = smtplib.SMTP(smtp_server,25)
#server.set_debuglevel(1)
server.login(from_addr,passwd)
server.sendmail(from_addr,[to_addr],msg.as_string())
server.quit()
