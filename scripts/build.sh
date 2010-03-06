#!/bin/bash

DIR="`pwd`"
ARGS="makeapp $@ -t console -a -o "$DIR/maximus" "$DIR/maximus.bmx""
if type bmkd; then
	COMMAND=bmkd
else
	COMMAND=bmk
fi

echo $COMMAND $ARGS
exec $COMMAND $ARGS
