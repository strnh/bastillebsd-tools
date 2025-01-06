#!/bin/sh
#
# usage: $0 $1 ($1= ansible inventory groupname)
#

/usr/local/bin/ansible 2>/dev/null -o -m raw  --become -a "export i={{inventory_hostname}} && jls -n \
" -l "!*@*" $1 | awk '{ for(i=1;i<NF;i++) { if ($i~"^name") print substr($i,6)"@"$1 }}' 
