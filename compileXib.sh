#!/bin/bash
shopt -s nullglob

log="/Users/$USER/Desktop/log.txt"
touch $log

#log="/dev/null"

ibtoolCommand="ibtool --errors --warnings --output-format human-readable-text --compile $2 $1"
echo $ibtoolCommand >> $log
($ibtoolCommand)&
