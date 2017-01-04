#!/bin/bash
# Ustawienia Bazy
export N4L_API_DATABASE_USER="na4lapy"
export N4L_API_DATABASE_PASS=__PASSWORD__
# Numer portu
export N4L_API_LISTEN_PORT=8000
# Katalog do przechowywania zdjęć
export N4L_API_IMAGES_PATH="/home/na4lapy/n4l-photos/1/"
# Odkomentuj, jeśli aplikacja ma pracować w trybie zgodności ze starym API
# export N4L_OLDAPI_IMAGES_URL="/opt/"

start-stop-daemon --start --oknodo --user na4lapy --pidfile /tmp/na4lapyapiswift.pid --startas /opt/na4lapy-api-swift/Na4lapyAPI/.build/debug/Na4lapyAPI -m &
