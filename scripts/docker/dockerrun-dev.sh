#!/bin/bash

/usr/bin/docker run -d --log-driver=syslog -e N4L_API_LISTEN_PORT=5555 -e N4L_API_DATABASE_NAME='na4lapydev' -e N4L_API_DATABASE_PASS=XXXXXX -e N4L_API_IMAGES_PATH='/opt/1/' -v /home/na4lapy/n4l-photos-dev:/opt --network host --name na4lapyapidev na4lapy/api:latest

echo "Stopping docker container..."
/usr/bin/docker stop -t 2 na4lapyapidev
