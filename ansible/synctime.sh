#!/bin/bash
#添加定时任务
ansible all -m cron -a "name='sync time' minute=0 hour=0 user=root job='/usr/sbin/ntpdate cn.ntp.org.cn'"
#删除定时任务
#ansible all -m cron -a "name='sync time' state=absent"
