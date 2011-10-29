#!/bin/sh

MODE=`xrandr | sed -n -e '/VGA1/{n;p}'| awk '{print $1}'`
test -z $MODE && exit 1
xrandr  | sed -n -e '/VGA1/,$p' | grep -q \* && xrandr --output VGA1 --off || xrandr --output VGA1 --mode $MODE
