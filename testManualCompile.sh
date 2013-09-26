#!/bin/bash
shopt -s nullglob

#log="/Users/$USER/Desktop/log.txt"
#touch $log

log="/dev/null"

xibFiles="${SRCROOT}/Example/XibExporterExample/Assets/Xibs/*.xib"

echo $xibFiles > $log
for xibFile in $xibFiles
do
	fileName=`basename $xibFile .xib`;
    nibFileNamePath="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${fileName}.nib"

    rm ${nibFileNamePath} 2>/dev/null

    ibtoolCommand="ibtool --errors --warnings --output-format human-readable-text --compile ${nibFileNamePath} $xibFile"
    echo $ibtoolCommand >> $log
    $ibtoolCommand
done