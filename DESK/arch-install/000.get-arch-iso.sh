#!/bin/bash

echo''
echo 'DOWNLOADING AND VERIFICATION OF THE LATEST ARCHLINUX ISO FILE:'
echo '============================================================='
echo''
# archlinux.org
ARCH_URL='archlinux.org'
echo -n "Reaching for $ARCH_URL ... "
if ping -c 1 "$ARCH_URL" > /dev/null 2>&1
    then
        echo "SUCCESS"
    else
        echo "FAILURE"
        exit 1
    fi

# https://archlinux.org/download/
ATCH_DL_PG='https://archlinux.org/download/'
ARCH_VER=$( curl -s $ATCH_DL_PG | grep Current\ Release | sed  -e 's/^.*<\/strong>\ \([0-9\.]*\)<\/li>/\1/' )
echo''
if [ -z $ARCH_VER ]
    then
        echo "FAILED to get the latest virsion date from $ARCH_DL_PG."
        exit 1
    else
        isoname=archlinux-$ARCH_VER-x86_64.iso
        echo "  VERSION: $ARCH_VER"
        echo "FILE NAME: $isoname"
    fi

# MIRROR LIST
# the county code, to filter out the mirror list.
[[ -z $1 ]] && CNTRY='RU' || CNTRY=$1
# the source url
MRRS_SRC="https://archlinux.org/mirrorlist/?country=${CNTRY}"

echo''
# iso and sig status
if [[ -f $isoname ]]
    then
        echo "There is an iso file in WD: $isoname"
        echo "Assuming it's the file"
        echo''
        ISO_ST=0
    else
        ISO_ST=1
    fi
if [[ -f $isoname ]]
    then
        echo "There is a sig file in WD: $isoname.sig"
        echo "Assuming it's the file"
        echo''
        SIG_ST=0
    else
        SIG_ST=1
    fi

# iteration trough the list
while read MRR
do
    if ping -c 1 "$MRR" > /dev/null 2>&1
        then
            urldir="https://$MRR/archlinux/iso/$ARCH_VER/"
            if [[ ! $ISO_ST -eq 0 ]]
                then
                    echo''
                    echo "Downloading $isoname"
                    echo '-------------'
                    curl $urldir$isoname -O
                    [ $? -eq 0 ] && ISO_ST=0
                    [ $ISO_ST -eq 0 ] &&\
                    echo''
                    echo "SUCCESSFUL downloading $isoname from $MRR"
                fi
            if [[ ! $SIG_ST -eq 0 ]]
                then
                    echo''
                    echo "Downloading $isoname.sig"
                    echo '-------------'
                    curl $urldir$isoname.sig -O
                    [ $? -eq 0 ] && SIG_ST=0
                    [ $SIG_ST -eq 0 ] &&\
                    echo''
                    echo "SUCCESSFUL downloading $isoname.sig from $MRR"
                fi
        fi

    # if iso and sig are successfully downloaded, then stop itaration.
    [[ $ISO_ST -eq 0 ]] && [[ $SIG_ST -eq 0 ]] && break 

done <<< $( wget -q -O - "$MRRS_SRC" | sed -n 's/^#Server\ =\ https.*\/\/\([^\/]*\)\/.*$/\1/p' )

[[ !  $ISO_ST -eq 0 ]] &&\
    echo "FAILED to find and get the $isoname" && exit 1
[[ !  $ISO_ST -eq 0 ]] &&\
    echo "FAILED to find and get the signature file $isoname"

echo''
echo''
# VERIFICATION
echo 'VERIFICATION::'
echo '============'
echo''
# gpg signature
echo '1. Signature verification:'
echo '   ----------------------'
if [[ !  $ISO_ST -eq 0 ]]
    then
        echo "  No sig file."
    else
        gpg --keyserver-options auto-key-retrieve\
            --keyserver=hkp://pool.sks-keyservers.net\
            --verify $isoname.sig
    fi
echo''
# sha1
echo -n "2. SHA1: "
arch_sha1=$( curl -s $ATCH_DL_PG | grep SHA1 | sed  -e 's/^.*<\/strong>\ \([0-9a-zA-Z]*\)<\/li>/\1/')
echo "$arch_sha1"
[[ -z $arch_sha1 ]] &&\
    echo "FAILED to get SHA1 hash, from $ATCH_DL_PG" ||\
    echo "$arch_sha1 $isoname" | sha1sum -c -
echo''
# md5
echo -n "3. MD5: "
arch_md5=$( curl -s $ATCH_DL_PG | grep MD5 | sed  -e 's/^.*<\/strong>\ \([0-9a-zA-Z]*\)<\/li>/\1/')
echo "$arch_md5"
[[ -z $arch_md5 ]] &&\
    echo "FAILED to get MD5 hash, from $ATCH_DL_PG" ||\
    echo "$arch_md5 $isoname" | md5sum -c -
echo''
