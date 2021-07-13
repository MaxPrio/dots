#!/bin/bash

DOTS_DIR=$HOME/.dots.git
DOTS_REP_URL="https://github.com/maxprio/dots.git"
BKP_DIR=$HOME/.dots-backup

echo ".dots.git" > .gitignore
git clone --bare $DOTS_REP_URL $DOTS_DIR
dots-git-cmd () {
   /usr/bin/git --git-dir=$DOTS_DIR/ --work-tree=$HOME $@
}
dots-git-cmd checkout 2>&1
if [ $? = 0 ]; then
  echo "Checked out dots.";
  else
    echo "Backing up pre-existing dots files.";
  mkdir -p "$BKP_DIR" 
  dots-git-cmd checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} "$BKP_DIR"/{}
  dots-git-cmd checkout
fi;
dots-git-cmd config status.showUntrackedFiles no
dots-git-cmd remote rename origin github
