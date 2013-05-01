#!/bin/sh

SU="sudo"
#set -x
if [ `whoami` != "root" ]; then
    $SU $0
    exit $?
fi

TPL="auto wlan0\niface wlan0 inet dhcp"
CONFDIR="/etc/network/interfaces.d"

error () {
    echo "$1"
    exit 1
}

clean () {
    mkdir -p $CONFDIR
    rm -f $CONFDIR/active
    killall dhclient
    killall wpa_suplicant
    rm -f /var/run/wpa_supplicant/*
}

is_disconnected () {
    iwconfig $1 | grep -q Not-Associated
}

scan () {
    dev=$1
    ip link set $dev up
    sleep 1
    iwlist $dev scan | sed -n 's/.*ESSID:\"\(.*\)\"/\1/p' | while read essid
    do
        file=`grep -Rl "wpa-ssid $essid$" $CONFDIR | head -1`
        test -z "$file" && continue
        ln -fs "$file" $CONFDIR/active
        ifdown $dev
        ifup $dev
        sleep 1
        exit 0
    done
}

create () {
    tmp=`mktemp`
    # ceni doesn't like empty files :(
    echo $TPL > $tmp
    ceni --iface wlan0 --file $tmp
    grep -q wpa-ssid $tmp && mv $tmp $CONFDIR/ || rm -f $tmp
}

scan () {
    ip link set $dev up
    iwlist $dev scan | sed -n 's/.*ESSID:\"\(.*\)\"/\1/p' | while read essid
    do
        file=`grep -Rl "wpa-ssid $essid$" $CONFDIR`
        test -z "$file" && continue
        ln -fs "$file" $CONFDIR/active
        ifdown $dev
        ifup $dev
        is_disconnected $dev || break
    done
}

# if $1 is empty - try first
dev=`iwconfig $1 2>/dev/null | awk 'NR==1{print $1}'`
test -z $dev && error "No wireless device detected"
# already connected, nothing to do
is_disconnected $dev || exit 0
clean
scan
test -f $CONFDIR/active && exit 0
test -z $SHELL && exit 1 || create
