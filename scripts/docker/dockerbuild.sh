#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "./dockerbuild </path/to/api.deb>"
	exit
fi
NAME=`basename $1`
VERSION=`echo $NAME | sed -e "s/.deb$//" | cut -d "_" -f 2`

echo $VERSION

if [ -z $VERSION ]; then
	echo "Bad version!"
	exit
fi

cp $1 na4lapyapi.deb
docker build -t na4lapy/api:latest .
docker tag na4lapy/api:latest na4lapy/api:$VERSION
rm na4lapyapi.deb
