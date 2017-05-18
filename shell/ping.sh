#!/bin/bash

for i in {1..254};
do
	ping -c 1 192.168.199.$i > /dev/null
	if [ $? = 0 ];then
		echo "192.168.199.$i is alive";
	fi 
done
