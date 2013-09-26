#!/bin/bash
shopt -s nullglob

log="/Users/$USER/Desktop/log.txt"
touch $log

#log="/dev/null"

appPath=$1
nibPath=$appPath

plistBuddy="/usr/libexec/PlistBuddy -c "
plistFileNamePath="$appPath/Info.plist"

xcodeProjectFolder=$($plistBuddy "Print XcodeProjectFolder" $plistFileNamePath)
xibRootRelativeFolder=$($plistBuddy "Print XIBRootRelativeFolder" $plistFileNamePath)
xibRoot="$xcodeProjectFolder/$xibRootRelativeFolder"

echo "Xib Root: $xibRoot" > $log

xibFiles="$xibRoot/*.xib"

for xibFile in $xibFiles
do
    echo Compiling $xibFile
	fileName=`basename $xibFile .xib`;
    nibFileNamePath="$nibPath/${fileName}.nib"

    rmCommand="rm ${nibFileNamePath}"
    echo $rmCommand >> $log
    $rmCommand 2>/dev/null

    ibtoolCommand="ibtool --errors --warnings --output-format human-readable-text --compile ${nibFileNamePath} $xibFile"
    echo $ibtoolCommand >> $log
    $ibtoolCommand
done