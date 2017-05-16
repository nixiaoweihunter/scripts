#!/bin/bash
#
# chkconfig: - 85 12

restapp_dir=

base_dir=$(dirname $0)
restapp_dir=${restapp_dir:-$base_dir}
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin





start() {
	 nohup /root/python27/bin/python manage.py runserver 0.0.0.0:8000 >> ./app.log 2>&1 &
            sleep 1
            ps axu | grep 'runserver' | grep -v 'grep' &> /dev/null
            if [ $? == '0' ];then
                echo "Start service ok"
            fi
}


stop() {
    ps -ef | grep runserver | grep -v 'grep' | awk '{print $2}' | xargs kill -9 &> /dev/null
    if [ $? == '0' ];then
	echo "Stop service ok"
    fi

}

status(){
    ps axu | grep 'runserver' | grep -v 'grep' &> /dev/null
    if [ $? == '0' ];then
        echo "restapp is running..."
    else
        echo "restapp is not running."
    fi
}



restart(){
    stop
    start
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;

  restart)
        restart
        ;;

  status)
        status
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 2
esac
