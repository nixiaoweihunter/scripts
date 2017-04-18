#!/bin/bash
# ymm environment init script
# Release：0.0.4
IP=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 |grep IPADDR|awk -F "=" '{print $2}'`
HOSTNAME=$1

if [ $# -eq 0 ];then
	echo -e "please input hostname\nexample: sh init.sh ymm-app-100"
	exit 1
fi

# change hostname
hostname $HOSTNAME
sed -i "s/HOSTNAME=.*/HOSTNAME=$HOSTNAME/g" /etc/sysconfig/network
echo "change hostname success !"

# cat zookeeper logdir init
if [ ! -d /data/appdatas/cat ];then
mkdir -p /data/appdatas/cat
cat > /data/appdatas/cat/client.xml << EOF
<config mode="client">
        <servers>
                <server ip="10.168.243.117" port="2280" />
        </servers>
</config>
EOF
fi
echo "monitor cat init success !"

if [ ! -d /data/webapps ];then
mkdir -p /data/webapps
cat > /data/webapps/appenv << EOF
deployenv=product
zkserver=10.252.106.1:2181,10.252.115.52:2181,10.252.104.46:2181
EOF
fi
if [ ! -d /data/applogs ];then
mkdir -p /data/applogs
fi
chown -R ymmapp.ymmapp /data/appdatas /data/webapps /data/applogs

# install pushconfig
if [ ! -d /usr/local/pushconfig ];then
wget 10.132.39.155/package/pushconfig.tar.gz -P /tmp/
tar xf /tmp/pushconfig.tar.gz -C /usr/local/
rm -f /tmp/pushconfig.tar.gz
fi


# change /etc/hosts /etc/resolv.conf
cat > /etc/hosts << EOF
127.0.0.1	localhost
$IP	$HOSTNAME
EOF
cat > /etc/resolv.conf << EOF
options timeout:1 attempts:1 rotate
nameserver      10.132.39.155
nameserver      10.168.27.183
EOF

# change /etc/sysctl.conf /etc/security/limits.conf
cat > /etc/sysctl.conf << EOF
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
vm.swappiness = 1
fs.file-max = 655360
net.core.netdev_max_backlog = 65535
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.somaxconn = 8192
net.ipv4.ip_local_port_range = 20000 65535
net.ipv4.tcp_mem = 12582912 12582912 12582912
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 65535
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_retries2 = 5
EOF
sysctl -p > /dev/null
echo "sysctl set OK !"


# intall zabbix_agent
killall zabbix_agentd
rm -rf /data/zabbix/
if [ ! -d /data/zabbix ]
then
	wget 10.132.39.155/package/zabbix.tar.gz -P /tmp/
	tar xf /tmp/zabbix.tar.gz -C /data/
#	sed -i "s/^ListenIP=.*/ListenIP=$IP/" /data/zabbix/etc/zabbix_agentd.conf
	sed -i "s/^ListenIP=.*/ListenIP=0.0.0.0/" /data/zabbix/etc/zabbix_agentd.conf
	netstat -tnlp|grep 10050 >/dev/null || /data/zabbix/sbin/zabbix_agentd -c /data/zabbix/etc/zabbix_agentd.conf
	grep zabbix /etc/rc.local >/dev/null || echo "/data/zabbix/sbin/zabbix_agentd -c /data/zabbix/etc/zabbix_agentd.conf" >> /etc/rc.local
	rm -f /tmp/zabbix.tar.gz
else
#	sed -i "/ListenIP=0.0.0.0/a \ListenIP=$IP" /data/zabbix/etc/zabbix_agentd.conf
	sed -i "/ListenIP=0.0.0.0/a \ListenIP=0.0.0.0" /data/zabbix/etc/zabbix_agentd.conf
	sed -i "/EnableRemoteCommands=0/a \EnableRemoteCommands=1" /data/zabbix/etc/zabbix_agentd.conf
	killall zabbix_agentd
	sleep 3
	/data/zabbix/sbin/zabbix_agentd -c /data/zabbix/etc/zabbix_agentd.conf
fi
echo "zabbix install success !"

# install JDK and tomcat
if [ ! -d /data/java ];then
wget 10.132.39.155/package/java.tar.gz -P /tmp/
tar xf /tmp/java.tar.gz -C /data/
rm -f /tmp/java.tar.gz
cat > /etc/profile.d/java.sh << EOF
export JAVA_HOME=/data/java
export JRE_HOME=/data/java
export PATH=\$PATH:\$JAVA_HOME/bin
export CLASSPATH=\$JAVA_HOME/lib:\$CONF_DIR
EOF
source /etc/profile
echo "java init success !"
fi

if [ ! -d /data/template-tomcat ];then
wget 10.132.39.155/package/template-tomcat.tar.gz -P /tmp/
tar xf /tmp/template-tomcat.tar.gz -C /data/
chown -R ymmapp.ymmapp /data/java/ /data/template-tomcat/
rm -f /tmp/template-tomcat.tar.gz
fi

# install deploy-agent
if [ ! -d /usr/dp ];then
wget 10.132.39.155/package/dp.tar.gz -P /tmp/
tar xf /tmp/dp.tar.gz -C /usr/
rm -f /tmp/dp.tar.gz
fi
su - ymmapp -c 'cd /usr/dp/ && /opt/python/bin/python agent_deploy.py restart'

chown ymmapp.ymmapp /data/

# add clear log script
if [ ! -d /opt/scripts ];then
mkdir /opt/scripts
fi
if [ ! -e /opt/scripts/clear_tomcat_log.sh ];then
wget 10.132.39.155/package/clear_tomcat_log.sh -P /opt/scripts/
chmod +x /opt/scripts/clear_tomcat_log.sh
fi
if [ ! -e /etc/logrotate.d/catalina ];then
wget 10.132.39.155/package/catalina -P /etc/logrotate.d/
fi
grep clear_tomcat_log.sh /etc/crontab >/dev/null 2>&1
if [ $? -ne 0 ];then
echo "1 2 * * * root /bin/bash /opt/scripts/clear_tomcat_log.sh >/dev/null 2>&1" >> /etc/crontab
fi

# add tomcat start script
if [ ! -e /opt/scripts/start_tomcat.sh ];then
wget 10.132.39.155/package/start_tomcat.sh -P /opt/scripts/
chmod +x /opt/scripts/start_tomcat.sh
fi
grep start_tomcat.sh /etc/rc.local >/dev/null || echo "/opt/scripts/start_tomcat.sh" >> /etc/rc.local

# change default vim
#mv /usr/bin/vim /usr/bin/vimymm
#mv /bin/vi /bin/viymm
#wget 10.132.39.155/package/vim -P /usr/bin/
#chmod +x /usr/bin/vim
#wget 10.132.39.155/package/vi -P /bin/
#chmod +x /bin/vi

# add cpu monitor config
wget 10.132.39.155/package/zabbix-percpu -P /etc/cron.d/
wget 10.132.39.155/package/zabbix_percpu.sh -P /opt/scripts/
chmod +x /opt/scripts/zabbix_percpu.sh

# change key
sed -i '/yj@jaro/d' /root/.ssh/authorized_keys
grep mwang@xxx /root/.ssh/authorized_keys >/dev/null 2>&1 || echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1tp586IP5XDKqcdVa0ZtRC8hLMG3IJqCqdiSVVOQi0wvR/fbYPp+cdhx+oejW8rGX90MY1rgED2kPqSDw+d6MGUIy5E9DWQM8HkDqWmRMn6gEDdWr1dnUa9JvJqLCFpP2AB3YX8UX/sdZbZizaQdM4rFTFR4IYkYu7tde1IxfoDgtuQtjELDMdjWmMaLVogbPmJX9/CsxiGc5PfvaLH0da0c04x4Q1ERAfSOIivwzlbmaj2V5qyTLbDgBzC1E47QeL5SDa5ynQPIrfpAMmmNBtzaWJTcHbcnnCATOaadfI4n1TRk81VZKYDB6KwknnHxdxc/CtQLXCGrF5QH3t5SL mwang@xxx" >> /root/.ssh/authorized_keys

echo "system init Ok !"
