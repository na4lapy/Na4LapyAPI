#!/bin/bash

/usr/bin/docker run -d --log-driver=syslog -e N4L_API_LISTEN_PORT=5555 -e N4L_API_DATABASE_NAME='na4lapyprod' -e N4L_API_DATABASE_PASS=XXXX -e N4L_API_IMAGES_PATH='/opt/1/' -v /home/na4lapy/n4l-photos:/opt --network host --name na4lapyapi na4lapy/api:latest


