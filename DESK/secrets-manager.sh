#!/bin/bash

GPGID=maxprio
KEYSF="$GPGID.gpg.keys.aes"
GPGSSHPUBF="$GPGID.gpg.ssh.pub"
TRUSTF="$GPGID.gpg.trust"

# General funcrions
#------------------

def-gpg-tty () {
# for the gpg-agent promt to be here.
  export GPG_TTY=$(tty)
}

remove-duplicate-lines () {
  [ -f "$1.bkp" ] && rm "$1.bkp"
  mv "$1" "$1.bkp"
  cat "$1.bkp" | sort | uniq > "$1"
  rm "$1.bkp"
}

# Restore funcrions
#------------------

import-keys () {
  local keysf
  keysf="$1"
  if [ -f $keysf ]
    then
      echo "Restoring gpg keys..."
      read -sp 'Enter backup passphrase: ' SPASSF
      echo ''
      gpg -d --yes --batch --passphrase-file <(echo "$SPASSF") "$keysf" | gpg --import -
    else
      echo "Can not find the backup keys file: '$keysf'"
  fi
}

import-trust () {
  local trustf
  trustf="$1"
  if [ -f $trustf ]
    then
      echo "Restoring gpg trust data..."
      gpg --import-ownertrust < "$trustf" 
    else
      echo "Can not find the ownertrust file: '$trustf'"
  fi
}


gpg-ssh-setup () {

  local gpgsshpub
  gpgsshpub="$1"

  [ -d ~/.ssh ] || mkdir ~/.ssh

  if [ -f authorized_keys ]
    then
      echo "Restorring authorized_keys file..."
      [ -f ~/.ssh/authorized_keys.bkp ] && rm ~/.ssh/authorized_keys.bkp
      [ -f ~/.ssh/authorized_keys ] && mv ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bkp
      cp authorized_keys ~/.ssh/
    else
      echo "Can not find authorized_keys file."
  fi

  if [ -f known_hosts ]
    then
      echo "Restorring known_hosts file..."
      [ -f ~/.ssh/known_hosts.bkp ] && rm ~/.ssh/known_hosts.bkp
      [ -f ~/.ssh/known_hosts ] && mv ~/.ssh/known_hosts ~/.ssh/known_hosts.bkp
      cp known_hosts ~/.ssh/
    else
      echo "Can not find known_hosts file."
  fi


  echo "Exporting gpg pub key, in ssh format..."
  [ -f $gpgsshpub ] && rm $gpgsshpub
  [ -f ~/.ssh/$gpgsshpub.bkp ] && rm ~/.ssh/$gpgsshpub.bkp
  [ -f ~/.ssh/$gpgsshpub ] && mv ~/.ssh/$gpgsshpub ~/.ssh/$gpgsshpub.bkp
  gpg --export-ssh-key $GPGID > ~/.ssh/$gpgsshpub

  cat ~/.ssh/$gpgsshpub >> ~/.ssh/authorized_keys
  remove-duplicate-lines ~/.ssh/authorized_keys

  echo "# The gpg auth keygrip for ssh-auth:" >> ~/.gnupg/sshcontrol
  gpg -k --with-keygrip | sed -n "/\[A\]/,\$p" | sed -n 's/^.*Keygrip\ =\ //p' >> ~/.gnupg/sshcontrol
  remove-duplicate-lines  ~/.gnupg/sshcontrol

 cat > ~/.ssh/ssh.notes.txt << 'EOF'
# Authorize the key on remote server(s) with:
ssh-copy-id -f -i ~/.ssh/user.gpg.ssh.pub user@server
#or by hand (github):
$ echo -n "$(cat ~/.ssh/user.gpg.ssh.pub )" | xsel -i -b
EOF

}

dots-set-sshurl () {
  local dots_command
  dots_command="git --git-dir=$HOME/.dots.git --work-tree=$HOME"
  if $dots_command remote -v | grep 'https://' > /dev/null 2>&1
    then
      echo "Changing dots remote URL, from 'https' to 'ssh' format."
      local giturl gitsshurl gitname
      giturl="$( $dots_command remote -v | head -1 | tr '\t ' ' ' | cut -d ' ' -f 2 )"
      gitsshurl="$( echo -n "$giturl" | sed 's/https:\/\//git@/;s/\//:/' )"
      gitname="$( $dots_command remote | head -1 )"
      $dots_command remote set-url $gitname $gitsshurl
    else
      echo "Can not find dots remote URL, in 'https' format."
  fi
  echo "DOTS REMOTE:"
  $dots_command remote -v
}

# Backup functions
#-----------------

# Commands
#---------

sm-cmd-restore () {
def-gpg-tty
import-keys $KEYSF
import-trust $TRUSTF
gpg-ssh-setup $GPGSSHPUBF
dots-set-sshurl
}
KEYSF="$GPGID.gpg.keys.aes"
TRUSTF="$GPGID.gpg.trust"
GPGSSHPUBF="$GPGID.gpg.ssh.pub"

# Main
#-----

sm-dispatcher () {
 local sm_cmd
 sm_cmd=$1
 case $sm_cmd in
   restore ) sm-cmd-restore
             ;;
         * ) echo "Unknown command '$sm_cmd'"
             exit 1
             ;;
 esac
}

sm-dispatcher $1
