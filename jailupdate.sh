#!/bin/sh
# bastille upgraded: 0.10.20231125_1 -> 0.13.20250126 
# 
VERSION=$(bastille version | awk -F"." '{print $1"."$2}' )
OLD=0.10

if [ "`echo \"if (${VERSION} > ${OLD}) 1\" | bc`" -eq 1 ] ; then
 
 /usr/local/bin/bastille list -a | awk  '{ if ($1!="JID") print "bastille update " $5  }'  | /bin/sh -x

else

/usr/local/bin/bastille list -a | awk  '{ if ($1!="JID") print "bastille update " $1  }'  | /bin/sh -x

fi
