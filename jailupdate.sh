#!/bin/sh

/usr/local/bin/bastille list -a | awk  '{ if ($1!="JID") print "bastille update " $1  }'  | /bin/sh -x
