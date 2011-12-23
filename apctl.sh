#!/bin/sh

cmd=$1
LOCK=/tmp/.apctl.lock

deadbeef_run ()
{
    which deadbeef >/dev/null && pgrep deadbeef >/dev/null 
}

deadbeef_np ()
{
    deadbeef --nowplaying %a 2>/dev/null | grep -qv ^nothing
}

deadbeef_next ()
{
    deadbeef --next
}

deadbeef_prev ()
{
    deadbeef --prev
}

deadbeef_toggle ()
{
    deadbeef --play-pause
}

xmms2_run ()
{
    which nyxmms2 >/dev/null && pgrep xmms2d >/dev/null
}

xmms2_np ()
{
    nyxmms2 current | grep -q ^Playing
}

xmms2_next ()
{
    nyxmms2 next
}

xmms2_prev ()
{
    nyxmms2 prev
}

xmms2_toggle ()
{
    nyxmms2 toggle
}

test -e $LOCK && exit 
touch $LOCK

for pl in xmms2 deadbeef
do
    ${pl}_run && ${pl}_${cmd} 2>/dev/null
done

rm $LOCK
