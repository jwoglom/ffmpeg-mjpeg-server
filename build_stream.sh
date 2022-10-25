#!/bin/sh

if [[ "$STREAM_URL" == "" ]]; then
	echo "STREAM_URL environment variable not found" >&2;
	exit 0;
fi

cat /stream.template|sed 's~STREAM_URL~'"$STREAM_URL"'~'
