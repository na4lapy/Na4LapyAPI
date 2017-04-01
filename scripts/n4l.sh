#!/bin/sh

#
# Function that starts the daemon/service
#
do_start()
{
# Ustawienia Bazy
export N4L_API_DATABASE_USER="na4lapy"
export N4L_API_DATABASE_PASS=__PASSWORD__
# Numer portu
export N4L_API_LISTEN_PORT=8000
# Katalog do przechowywania zdjęć
export N4L_API_IMAGES_PATH="/home/na4lapy/n4l-photos/1/"
# Odkomentuj, jeśli aplikacja ma pracować w trybie zgodności ze starym API
# export N4L_OLDAPI_IMAGES_URL="/opt/"

	/sbin/start-stop-daemon --start --oknodo --user na4lapy --pidfile /tmp/na4lapyapi.pid --startas /usr/local/na4lapyapi/Server -m &
}

#
# Function that stops the daemon/service
#
do_stop()
{
	/sbin/start-stop-daemon --quiet --stop --remove-pidfile --pidfile /tmp/na4lapyapi.pid
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
