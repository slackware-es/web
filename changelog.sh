#!/bin/bash

VERSION=${1:-current}
MIRROR="/var/www/slackware.es/public/files/slackware"
CHANGELOG="$MIRROR/slackware64-$VERSION/ChangeLog.txt"

echo "Last: |" 
sed '/+--------------------------+/,$d ; s/^/    /g ; 10q ' $CHANGELOG 
