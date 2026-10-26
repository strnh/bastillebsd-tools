#!/bin/sh
if [ "$1" == '' ]; then
  echo "Usage: " $0 " pkgs " 
  exit 1
fi 

pkgexists=$(pkg info -e $1) 
if [ $? == 1 ]; then
 echo "pkg " $1 " not installed."
fi

PKG=$1

mkdir /tmp/$$-work
cd /tmp/$$-work
DIR=$(pwd)
PKGFILE=$(pkg create $PKG | awk '{print $NF}').pkg
echo "1" | awk '{print "pwd" }' | sh -x
jls -n | awk '{ for(i=1;i<NF;i++){ if (substr($i,1,4)=="name") { print $i }}}' | sed 's/name=//g' | awk -v pkgfile=$PKGFILE '{print "pwd && cp \"" pkgfile  "\"  /usr/local/bastille/jails/"$1"/root/root/; bastille pkg "$1" add ./"pkgfile }'  | sh -x 

#
rm -r $DIR
