#!/bin/sh
if [ $1=="" ]; then
 echo "Usage: "$0 " pkgname (ex: pkgdist.sh brotli) "
 exit 1; 
fi 
PKG=$1

mkdir /tmp/$$-work
cd /tmp/$$-work
DIR=$(pwd)
PKGFILE=$(pkg create $PKG | awk '{print $NF}').pkg
echo "1" | awk '{print "pwd" }' | sh -x
jls -n | awk '{print $11 }' | sed 's/name=//g' | awk -v pkgfile=$PKGFILE '{print "pwd && cp \"" pkgfile  "\"  /usr/local/bastille/jails/"$1"/root/root/; bastille pkg "$1" add ./"pkgfile }'  | sh -x 

#
rm -r $DIR
