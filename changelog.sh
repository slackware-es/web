#!/bin/bash

VERSION=${1:-current}
CHANGELOG="/mnt/slack/slackware/slackware64-$VERSION/ChangeLog.txt"

echo "Last: |" 
sed '/+--------------------------+/,$d ; s/^/    /g ; 10q ' $CHANGELOG 
