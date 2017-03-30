#!/bin/sh

#
# Function that starts the daemon/service
#
do_start()
{

. /etc/na4lapyapi-dev.conf

	/sbin/start-stop-daemon --start --oknodo --user na4lapy --pidfile /tmp/na4lapyapi-dev.pid --startas /usr/local/na4lapyapidev/Server -m &
}

#
# Function that stops the daemon/service
#
do_stop()
{
	/sbin/start-stop-daemon --quiet --stop --remove-pidfile --pidfile /tmp/na4lapyapi-dev.pid
}

case "$1" in
	start)
		do_start
		;;
	stop)
		do_stop
		;;
	restart)
		do_stop
		do_start
		;;
	*)
		echo "Usage: {start|stop|restart}" >&2
		exit 3
		;;
esac

:
