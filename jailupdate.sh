#!/bin/sh
#
# 2026/02/24 rewrite.
#
set -ue
#
/usr/local/bin/bastille list | awk  '{ if ($1!="JID") print "PAGER='cat'  freebsd-update fetch install --not-running-from-cron -j " $1  }'  | /bin/sh -x
