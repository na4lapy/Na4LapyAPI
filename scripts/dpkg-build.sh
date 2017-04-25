#!/bin/bash

REPODIR=/opt/Na4LapyAPI
PAYMENTS=Views/Payments

VERSION=`cat $REPODIR/DEBIAN/control | grep ^Version | cut -d " " -f2`
PACKAGE=`cat $REPODIR/DEBIAN/control | grep ^Package | cut -d " " -f2`

ROOTDIR=$PACKAGE\_$VERSION
PACKAGEDIR=$ROOTDIR/usr/local/$PACKAGE
mkdir -p $PACKAGEDIR/$PAYMENTS/
cp $REPODIR/.build/debug/Server $PACKAGEDIR
cp $REPODIR/.build/debug/*.so $PACKAGEDIR
cp $REPODIR/$PAYMENTS/* $PACKAGEDIR/$PAYMENTS/
mkdir -p $ROOTDIR/DEBIAN
cp $REPODIR/DEBIAN/control $ROOTDIR/DEBIAN

dpkg-deb --build $ROOTDIR

