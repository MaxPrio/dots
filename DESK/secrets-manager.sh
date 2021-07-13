#!/bin/bash

GPGID=maxprio
KEYSF="$GPGID.gpg.keys.aes"
GPGSSHPUB="$GPGID.gpg.ssh.pub"

import-keys () {
  local keysf
  keysf="$1"
  if [ -f $keysf ]
    then
      read -sp 'Enter backup passphrase: ' SPASSF
      echo ''
      export GPG_TTY=$(tty) # for gpg-agent promts to be here.
      gpg -d --yes --batch --passphrase-file <(echo "$SPASSF") "$keysf" | gpg --import -
    else
      echo "Can not find the backup keys file: '$keysf'"
  fi
}

remove-duplicate-lines () {
  [ -f "$1.bkp" ] && rm "$1.bkp"
  mv "$1" "$1.bkp"
  cat "$1.bkp" | sort | uniq > "$1"
  rm "$1.bkp"
}


gpg-ssh-setup () {
  local gpgsshpub
  gpgsshpub="$1"
  [ -d ~/.ssh ] || mkdir ~/.ssh
  [ -f ~/.ssh/$gpgsshpub ] && mv ~/.ssh/$gpgsshpub ~/.ssh/$gpgsshpub.bkp
  gpg --export-ssh-key keyid > ~/.ssh/$gpgsshpub
  cat ~/.ssh/user.gpg.ssh.pub >> ~/.ssh/authorized_keys
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
      local giturl gitsshurl gitname
      giturl="$( $dots_command remote -v | head -1 | tr '\t ' ' ' | cut -d ' ' -f 2 )"
      gitsshurl="$( echo -n "$giturl" | sed 's/https:\/\//git@/;s/\//:/' )"
      gitname="$( $dots_command remote | head -1 )"
      $dots_command remote set-url $gitname $gitsshurl
  fi
  $dots_command remote -v
}
