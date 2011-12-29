#!/bin/sh


DELAY=60
BP="/sys/class/power_supply/BAT1"



hibernate()
{
    dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate
}

notify()
{
    echo $1| osd_cat -A right -d 2
}

checker()
{
    now=`cat $BP/charge_now`
    full=`cat $BP/charge_full`
    
    charge=$((now*100/full))
    
    test $charge -le 10 && {
        DELAY=$((charge*3))
        notify "BATTERY $charge%"
    } || DELAY=60
    test $charge -le 1 && hibernate
}
while true; do
    grep -q Charging $BP/status && continue
    checker
    sleep $DELAY
done
