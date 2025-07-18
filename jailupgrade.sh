#!/bin/sh
#
#  for 1.0.x
/usr/local/bin/bastille list | env VERSION=$(freebsd-version) awk  '{ if ($2!="JID") print "bastille upgrade  " $2 " " ENVIRON["VERSION"]  }'  | /bin/sh -x

/usr/local/bin/bastille list | awk '{if ($2!="JID") print "bastille upgrade " $2 " install " } ' | /bin/sh -x
/usr/local/bin/bastille restart ALL

/usr/local/bin/bastille list | awk '{if ($2!="JID") print "bastille upgrade "  $2 " install " } ' | /bin/sh -x
