#!/bin/bash

[[ -f "$1" ]] || exit 1
SRC_F="$1"

echo''
echo "DUMPING A FILE TO A BULK DEVICE, WITH DD"
echo "======================================="
echo''

echo 'Ditermine the target device:'
echo '---------------------------'
echo''

echo 'Make sure, the target device is unpluged?'
read -p "press y - to go on, or any other key to aboard._ " -n 1 -r
echo ''
[[ $REPLY =~ ^[Yy]$ ]] || exit 1


mk_dlist () {
    dlist=''
    while read line
        do
            dlist="$dlist$line;"
        done < <( lsblk | grep disk | tr -s ' ' | cut -d ' ' -f 1 )
    echo "$dlist"
}

DLIST1="$( mk_dlist )"

echo 'Plug the target device in.'
read -p "press y - to go on, or any other key to aboard._ " -n 1 -r
echo ''
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

DLIST2="$( mk_dlist )"

INDX=11
while [[ $DLIST1 == $DLIST2 ]] && [[ $INDX -gt 0 ]]
do
    echo "Nothing new is pluged in. Weiting 1s. ($INDX tryes left)..."
    sleep 1
    ((INDX--))
    DLIST2="$( mk_dlist )"
done
[[ $DLIST1 == $DLIST2 ]] && exit 1

echo ''
echo "The pluged in devices: before- ${DLIST1%;}"
echo "                          now- ${DLIST2%;}"
echo ''

fnd_new () {
# returns the first element of the second ';' separated list,
# that is not present in the first one, or nothing.

    hd1=${1%%;*}
    hd2=${2%%;*}
    tl1=${1#*;}
    tl2=${2#*;}

    [[ ! "$hd2" == "$hd1" ]] && [[ -z "$tl1" ]] && echo "$hd2"
    [[ ! "$hd2" == "$hd1" ]] && [[ ! -z "$tl1" ]] && fnd_new "$tl1" "$2"
    [[ "$hd2" == "$hd1" ]] && [[ ! -z "$tl2" ]] && fnd_new "$1" "$tl2"

}

DNEW=$(fnd_new "$DLIST1" "$DLIST2")
[[ -z $DNEW ]] && exit 1
VOL=$( lsblk | grep ^$DNEW | tr -s ' ' | cut -d ' ' -f 4 )

echo "The target device is $DNEW($VOL) ?."
read -p "press y - to go on, or any other key to aboard._ " -n 1 -r
echo ''
echo ''
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

echo "ALL THE PRESENT DATA ON THE TARGET DEVICE GOING TO BE DESTROYED !!!"
echo "SO, ONCE AGAIN:"
echo "The source file is: $SRC_F"
echo "The target device is $DNEW($VOL) ?."
read -p "press y - to go on, or any other key to aboard._ " -n 1 -r
echo ''
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

# umounting all partitions on the target device.
for disk in $(ls /dev/$DNEW[0-9]); do
	if grep -q $disk /proc/mounts; then
		sudo umount $disk
	fi;
done

sudo dd bs=4M if="$SRC_F" of=/dev/$DNEW status=progress oflag=sync

lsblk
