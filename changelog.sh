#!/bin/bash

VERSION=$1

echo "Last: |" 
wget -qO - ftp://ftp.osuosl.org/pub/slackware/slackware64-$VERSION/ChangeLog.txt | sed '/+--------------------------+/,$d ; s/^/    /g ; 10q ' 
