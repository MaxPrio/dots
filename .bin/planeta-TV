#!/bin/bash - 

CHLSTF=~/.config/planeta-tv-list.txt

#cat TVlist.vlc |\
wget -qO-  http://weburg.tv/playlist.vlc |\
    sed 's/<location>/\nlocation-/g;s/<\/location>/\n/g;s/<title>/title-/g;s/<\/title>/\n/g' |\
    sed -n '/^title\|^location/ s/^location-\|^title-//p' |\
    tr '\n' '|' |\
    sed 's/|\($\|udp:\)/\n\1/g' \
    > $CHLSTF

CHNAME=$(cat $CHLSTF | cut -d '|' -f 2 | sort | fzf )
CHADRS=$(cat $CHLSTF | grep "$CHNAME" | cut -d '|' -f 1 )
mpv $CHADRS
