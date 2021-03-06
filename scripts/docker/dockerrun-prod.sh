#!/bin/bash

DB_PASSWORD=""

# --------------------------------------- #

if [ -z $DB_PASSWORD ]; then
        echo "Edit this file and set DB_PASSWORD!"
        exit
fi

/usr/bin/docker run -d --log-driver=syslog -e N4L_API_LISTEN_PORT=8000 -e N4L_API_DATABASE_NAME='na4lapyprod' -e N4L_API_DATABASE_PASS=$DB_PASSWORD -e N4L_API_IMAGES_PATH='/opt/1/' -v /home/na4lapy/n4l-photos:/opt --network host --name na4lapyapi na4lapy/api:latest

echo "Stopping docker container..."
/usr/bin/docker stop -t 2 na4lapyapi

