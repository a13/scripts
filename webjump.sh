#!/bin/sh

NB="#122212"
NF="#DEDEDE"
SB="#445444"
SF="#EFEFEF"
ldd /usr/bin/dmenu | grep -q libXft && \
    FONT="Consolas-9" || \
    FONT="-*-terminus-medium-*-*-*-18-*-*-*-*-*-iso10646-*"

DMENU="dmenu -fn $FONT -nb $NB -nf $NF -sb $SB -sf $SF"
test -n "$1" && browser=$1 || exit 1

SEARCH="https://encrypted.google.com/search?ie=utf-8&oe=utf-8&aq=t&q="

case $browser in
    firefox)
        ROOT=$HOME/.mozilla/firefox
        DB=$ROOT/`sed -n 's/Path=\(.*\)/\1/p' $ROOT/profiles.ini`/places.sqlite
        TABLES="moz_places"
        FIELDS="title,url"
        ORDER="last_visit_date"
        ;;
    conkeror)
        ROOT=$HOME/.conkeror.mozdev.org/conkeror
        DB=$ROOT/`sed -n 's/Path=\(.*\)/\1/p' $ROOT/profiles.ini `/places.sqlite
        TABLES="moz_places"
        FIELDS="title,url"
        ORDER="last_visit_date"
        ;;
    chromium)
        DB=$HOME/.config/chromium/Default/History
        TABLES="urls"
        FIELDS="title,url"
        ORDER="last_visit_time"
        ;;
    midori)
        DB=$HOME/.config/midori/history.db
        TABLES="history"
        FIELDS="title,uri"
        ORDER="date"
        ;;
    luakit)
	DB=$HOME/.local/share/luakit/history.db
	TABLES="history"
	FIELDS="title,uri"
        ORDER="last_visit"
        ;;
    *)
        exit 1
        ;;
esac

urlstr=`sqlite3 "$DB" 'select '$FIELDS' from '$TABLES' order by '$ORDER' desc' | $DMENU -i -l 15`
#urlstr=`sqlite3 $DB 'select '$FIELDS' from '$TABLES | $DMENU`
test -z "$urlstr" && exit 1
echo "$urlstr" | grep -q \| && url=`echo $urlstr | cut -d \| -f 2` || url=$SEARCH$urlstr
$browser "$url"
