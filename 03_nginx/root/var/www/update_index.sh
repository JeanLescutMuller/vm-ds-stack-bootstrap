#!/bin/bash -xe

ROOT=$(dirname $0)

title=$(hostname -s)
full_title=$(hostname -f)
if [ -d $ROOT/html/html_links ]; then
	links=$(cat $ROOT/html/html_links/*.html)
fi

if [ -z "$links" ]; then
	echo 'It seems that there is no application installed on the server yet...'
fi


eval "cat <<EOF
$( < $ROOT/template.html.sh)
EOF
" 2> /dev/null > $ROOT/html/index.html
