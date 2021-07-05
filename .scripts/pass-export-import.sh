#!/bin/bash

# USAGE:$0 [ DIRECTORY | FILE ]

# Exports contents of the default or provided directory to ./<DIRECTORY_NAME>.tar.gz
# Imports from the default or provided file to ./<FILE_NAME (cut off '.tar.gz')>/

# All the .gpg files are reencrypted with a symmetric key, to be able to import to another gpg_id.


PS_FILE=passwords.asc    # the single file for all reencrypted .gpg files.
PRPHX='FILENAME:'   # the file name line prephix in PS_FILE.
PS_DFLT_PATH=~/.password-store
OUT_DIR="$( echo $PWD )"

# choosing the source file to import, or directory to expot from. 
if [[ -z "$1" ]]
    then
        [[ -f "${PS_DFLT_PATH##*/}.tar.gz" ]] \
            && PS_ARCH="${PS_DFLT_PATH##*/}.tar.gz" \
            || PS_PATH="$PS_DFLT_PATH"
    else
        [[ -f "$1" ]]\
            && PS_ARCH="$1" \
            || PS_PATH="$1"
    fi
# PS_ARCH;PS_PATH: one of the two is empty.

# if PS_ARCH is empty then export, otherwise import.
if [[ ! -z "$PS_PATH" ]]
    then # export
        [[ ! -d "$PS_PATH" ]] && echo "'""$PS_PATH""' Does not exist. EXIT..." && exit 1

        PS_ARCH="${PS_PATH##*/}.tar.gz"

        echo ''
        echo "EXPORT:"
        echo -n "'$PS_PATH/' ->>  './$PS_ARCH'"
        read -p "  ??? [y|any]:" -n 1 -r
        echo ''
        [[ $REPLY =~ ^[Yy]$ ]] || exit 1

        all-to-one (){
        while read passf
            do
                echo "$PRPHX$passf"
                gpg -d "$passf" 2>/dev/null

            done < <(find . -type f -name '*.gpg')
        }

        cd $PS_PATH

        # all the password entries -> plain text ->  a single encrypted file
        all-to-one | gpg --symmetric -o $PS_FILE

        # archiv the rest of the directory, along with the passwords file
        find . -type f ! -name *.gpg | tar -czf $OUT_DIR/$PS_ARCH -T -
        rm "$PS_FILE"
        cd - >/dev/null

    else # import

        [[ ! -f "$PS_ARCH" ]] && echo "'""$PS_ARCH""' Does not exist. EXIT..." && exit 1

        PS_DIR="${PS_ARCH%.tar.gz}"

        echo ''
        echo "IMPORT:"
        echo -n "./$PS_ARCH'  ->>  './$PS_DIR/'."
        read -p "  ??? [y|any]:" -n 1 -r
        echo ''
        [[ $REPLY =~ ^[Yy]$ ]] || exit 1
        echo ''
        echo 'GPG ID LIST:'
        gpg -k | grep uid | tr -s ' ' | cut -d ' ' -f 5,6
        echo ''
        read -p "Enter the gpg_id: "
        GPG_ID=$REPLY

        mkdir ./$PS_DIR

        tar -xzf ./$PS_ARCH -C ./$PS_DIR

        cd $PS_DIR
        while read line
            do
                if [[ "$line" =~ ^$PRPHX.* ]]
                    then
                        [[ ! -z $pentry ]] \
                            && echo -e ${pentry#\\n}  |\
                            gpg -o $pf_fname -e -r $GPG_ID
                        pentry=''

                        pf_fname=${line#$PRPHX}
                        pf_dir=${pf_fname%/*}

                        [[ ! -d $pf_dir ]] && mkdir -p "$pf_dir"
                    else
                        pentry="$pentry\n$line"
                    fi

            done < <( gpg -d $PS_FILE )
        cd - >/dev/null

    fi
