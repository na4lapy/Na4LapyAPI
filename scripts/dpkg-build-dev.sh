#!/bin/bash

REPODIR=/opt/Na4LapyAPI

VERSION=`cat $REPODIR/DEBIAN/control-dev | grep ^Version | cut -d " " -f2`
PACKAGE=`cat $REPODIR/DEBIAN/control-dev | grep ^Package | cut -d " " -f2`

ROOTDIR=$PACKAGE\_$VERSION
PACKAGEDIR=$ROOTDIR/usr/local/$PACKAGE
mkdir -p $PACKAGEDIR
cp $REPODIR/.build/debug/Server $PACKAGEDIR
cp $REPODIR/.build/debug/*.so $PACKAGEDIR
mkdir -p $ROOTDIR/DEBIAN
cp $REPODIR/DEBIAN/control-dev $ROOTDIR/DEBIAN/control

dpkg-deb --build $ROOTDIR

