#!/bin/sh
#
# usage: $0 $1 ($1= ansible inventory groupname)
#

/usr/local/bin/ansible 2>/dev/null -m raw  --become -a "export i={{inventory_hostname}} &&  /usr/local/bin/bastille \
list jail | awk '{print \$1\"@\"ENVIRON[\"i\"] }'" $1 | grep -v callback | grep -v rc | grep -v closed | grep -v bastille
