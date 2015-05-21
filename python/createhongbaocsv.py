#coding=utf-8
#!/usr/bin/python
import os
import MySQLdb
import time
import csv
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

date = time.strftime("%Y-%m-%d",time.localtime(time.time()))
#date = "2015-05-20"

os.chdir("/root/ni.xiaowei/hongbao/")

conn = MySQLdb.connect(host="10.10.3.105",user="o2o_readonly",passwd="o2o_readonly",port=3307,db="db_o2o",charset="utf8")
cursor = conn.cursor()

#订单明细
sql1 = "SELECT ma.market_name '卖场名称',op.order_sn '订单号',od.outer_order_sn 'oms订单号',order_amount '订单金额',op.balance_amount '余额支付',op.bonus_amount '红包金额',op.pay_amount '线上支付金额', CASE pay_code when 'zhifubao' THEN '支付宝' when 'umpay' THEN '联动支付' else '' END as '支付方式' FROM order_info od  LEFT JOIN market_info ma ON od.market_id =ma.market_id INNER JOIN order_payment op on op.order_sn =od.order_sn where op.create_date like '%s%%' and op.payment_status=2 AND ma.market_id='1'"

n1 = cursor.execute(sql1 % date)
result1=cursor.fetchmany(n1)

csvfile1 = file('订单明细.csv','wb')
writer = csv.writer(csvfile1)
writer.writerow(['卖场名称','订单号','oms订单号','订单金额','余额支付','红包金额','线上支付金额'])
for i in result1:
	writer.writerow(i)
csvfile1.close()

#根据卖场统计订单数量订单金额
sql2 = "SELECT zfmx.market_name '卖场名称',zfmx.`红包金额`,zfmx.`线上支付金额`,zfdd.`订单总金额`,zfdd.`订单数量` FROM (select ma.market_name,SUM(op.pay_amount) '线上支付金额',SUM(op.bonus_amount+op.balance_amount) '红包金额' from order_info oi LEFT JOIN market_info ma ON ma.market_id = oi.market_id inner JOIN order_payment op ON op.order_sn = oi.order_sn WHERE op.payment_status=2 AND op.create_date LIKE '%s%%' GROUP BY ma.market_name) zfmx ,(SELECT ma.market_name,SUM(od.order_amount) '订单总金额',COUNT(id) '订单数量' FROM (SELECT DISTINCT oi.* FROM order_info oi inner JOIN order_payment op ON op.order_sn = oi.order_sn WHERE op.payment_status=2 AND op.create_date LIKE '%s%%') od LEFT JOIN market_info ma ON ma.market_id = od.market_id GROUP BY ma.market_name) zfdd WHERE zfmx.market_name =zfdd.market_name"
n2 = cursor.execute(sql2 % (date,date))
result2=cursor.fetchmany(n2)

csvfile2 = file('根据卖场统计订单数量订单金额.csv','wb')
writer = csv.writer(csvfile2)
writer.writerow(['卖场名称','红包金额','线上支付金额','订单总金额','订单数量'])
for i in result2:
	writer.writerow(i)
csvfile2.close()


#红包发放明细
sql3 = "select '红包发放明细', ui.mobilephone '用户手机',count(ub.user_id) '数量',SUM(bl.amount) '金额' from user_bonus ub INNER JOIN user_info ui on ub.user_id=ui.user_id INNER JOIN bonus_lot bl on ub.lot_id=bl.id where ub.user_id >0 and ub.receive_date BETWEEN '%s 00:00:00' and '%s 23:59:59' group by ub.user_id"
n3 = cursor.execute(sql3 % (date,date))
result3=cursor.fetchmany(n3)

csvfile3 = file('红包发放明细.csv','wb')
writer = csv.writer(csvfile3)
writer.writerow(['红包发放明细','用户手机','数量','金额'])
for i in result3:
	writer.writerow(i)
csvfile3.close()

#红包使用明细-分商场
sql4 = "select mi.market_name '商场',oi.outer_order_sn 'oms订单号',op.outer_payment_sn 'oms流水号',ui.mobilephone '用户手机',oi.create_date '订单日期',count(op.id) '数量',SUM(IFNULL(op.bonus_amount,0) + IFNULL(op.balance_amount,0)) '红包数额' from order_info oi INNER JOIN order_payment op on oi.order_sn=op.order_sn LEFT JOIN user_info ui on oi.user_id=ui.user_id LEFT JOIN market_info mi on oi.market_id=mi.market_id where (op.has_bonus > 0 or op.has_balance >0) and op.payment_status in (2,4) and oi.order_from='oms' and oi.market_code and oi.create_date BETWEEN '%s 00:00:00' and '%s 23:59:59' group by  op.outer_payment_sn order by mi.market_name;"
n4 = cursor.execute(sql4 % (date,date))
result4 = cursor.fetchmany(n4)

csvfile4 = file('红包使用明细-分商场.csv','wb')
writer = csv.writer(csvfile4)
writer.writerow(['商场','oms订单号','oms流水号','用户手机','订单日期','数量','红包数额'])
for i in result4:
	writer.writerow(i)
csvfile4.close()


#余额发放明细
sql5 = "select '余额发放明细', ui.mobilephone '用户手机',count(ubl.id) '数量',SUM(IFNULL(ubl.change_money,0)) '金额' from user_balance_log ubl INNER JOIN user_info ui on ubl.user_id=ui.user_id where ubl.change_money > 0 and ubl.create_date BETWEEN '%s 00:00:00' and '%s 23:59:59' GROUP BY ubl.user_id;"
n5 = cursor.execute(sql5 % (date,date))
result5 = cursor.fetchmany(n5)

csvfile5 = file('余额发放明细.csv','wb')
writer = csv.writer(csvfile5)
writer.writerow(['余额方法明细','用户手机','数量','金额'])
for i in result5:
	writer.writerow(i)
csvfile5.close()


#余额和红包未使用统计
sql6 = "select '未使用红包',count(ub.user_id) '数量',SUM(bl.amount) '金额' from user_bonus ub INNER JOIN user_info ui on ub.user_id=ui.user_id INNER JOIN bonus_lot bl on ub.lot_id=bl.id where (ub.state=1 and ub.receive_date < '%s 00:00:00') or (ub.state=2 and ub.receive_date < '%s 00:00:00' and ub.used_date > '%s 00:00:00') UNION select '未使用余额', ' ' as '数量',SUM(IFNULL(ubl.change_money,0)) '金额' from user_balance_log ubl INNER JOIN user_info ui on ubl.user_id=ui.user_id where ubl.create_date < '%s 00:00:00' "
n6 = cursor.execute(sql6 % (date,date,date,date))
result6 = cursor.fetchmany(n6)

csvfile6 = file('余额和红包未使用统计.csv','wb')
writer = csv.writer(csvfile6)
writer.writerow(['未使用红包','数量','金额'])
for i in result6:
	writer.writerow(i)
csvfile6.close()



os.mkdir(date)
os.system("mv *.csv %s" % date)
