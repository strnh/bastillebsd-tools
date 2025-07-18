#!/bin/sh
# bastille upgraded: 0.10.20231125_1 -> 0.13.20250126
# bastille RELEASE 1.0.x : -> RELS
#
VERSION=$(bastille version | awk -F"." '{print $1"."$2}' )
OLD=0.10
NEW=0.13
NEW2=0.14
RELS=1.0

case $VERSION in 
 $OLD)
   /usr/local/bin/bastille list -a | awk  '{ if ($1!="JID") print "bastille update " $1  }'  | /bin/sh -x
 ;;
 $NEW)
    /usr/local/bin/bastille list -a | awk  '{ if ($1!="JID") print "bastille update " $5  }'  | /bin/sh -x
 ;;
 $NEW2)
   /usr/local/bin/bastille list -a | awk  '{ if ($1!="JID") print "bastille update " $5  }'  | /bin/sh -x
 ;;
 $RELS) 
   /usr/local/bin/bastille list | awk  '{ if ($1!="JID") print "bastille update " $2  }'  | /bin/sh -x
 ;;
 esac

fi

