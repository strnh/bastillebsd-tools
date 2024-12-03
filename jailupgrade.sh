#!/bin/sh
/usr/local/bin/bastille list -a | env VERSION="14.2-RELEASE" awk  '{ if ($1!="JID") print "bastille upgrade  " $1 " " ENVIRON["VERSION"]  }'  | /bin/sh -x

/usr/local/bin/bastille list -a | awk '{if ($1!="JID") print "bastille upgrade " $1 " install " } ' | /bin/sh -x

