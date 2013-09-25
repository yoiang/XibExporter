#!/bin/bash
# preprocess script for xib exporter
#
# creates a file indicating which xibs should be processed - uses md5s to determine if the file has changed since last process
# param 1 should be $SRCROOT from Xcode

#md5 comparisons
dir="$1";
output_file="$dir/changedViews.txt";
md5_file="$dir/viewMD5s.txt";
xibs=(`cat $md5_file`);
len=${#xibs[*]};
new_output="";
new_change="";

touch $output_file;
touch $md5_file;

all_xibs=`find $dir -name \*.xib`;

for f in $all_xibs
do
	fname=`basename $f`;
	cur_md5=`md5 -q $f`;
	process_file=1;
	
	i=0;
	while [ $i -lt $len ]
	do

		xib=${xibs[$i]};
		elems=(${xib//=/ });

		name=${elems[0]};
		md5=${elems[1]};

		if [ $fname == $name -a $md5 == $cur_md5 ]
		then
			process_file=0;
		fi

		let i++;

	done
	
	if [ $process_file -eq 1 ]
	then
		new_output="$new_output $fname";
	fi
	
	new_change="$fname=$cur_md5\n$new_change";
done

echo $new_output > $output_file;
echo -e $new_change > $md5_file;

