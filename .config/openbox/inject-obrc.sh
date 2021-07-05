#/bin/bash

cd ~/.config/openbox

[ -f rc.xml.bak ] && rm rc.xml.bak
mv rc.xml rc.xml.bak

# cuts out the file content, between the given pattern lines.
cut_out () {
    sed  "/$2/q" $1
    sed -n "/$3/,\$p" $1
}
# inserts the first file content, into the second, in front of  the pattern line.
injection () {
    sed -n "/$3/q;p" $2
    cat $1
    sed -n "/$3/,\$p" $2
}

cut_out rc.xml.original '<margins>' '<\/margins>' > rc.xml.temp
injection rc.xml.margins rc.xml.temp '<\/margins>' > rc.xml.temp2
injection rc.xml.keybindings rc.xml.temp2 '<\/keyboard>' > rc.xml.temp3
injection rc.xml.applications rc.xml.temp3 '<\/applications>' > rc.xml
rm rc.xml.temp*
cd -

#killall idesk
#openbox --restart
#~/.bin/rc-script.sh
