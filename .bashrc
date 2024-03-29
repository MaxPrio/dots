#!/bin/bash


# AUTOSTARTX:
#Start graphical server on tty1 if not already running.
[ "$(tty)" = "/dev/tty1" ] && ! pgrep -x Xorg >/dev/null && exec startx

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#path
export PATH="~/.bin:$PATH"

#vars
export EDITOR="vim"
  # sound fix for music ( look in ~/.asoundrc ) 
export ALSA_DIRECT="SPDIF0plug"
#export ALSA_DIRECT="USB1plug"

#Prompt
PS1='\[\e[01;38;5;240m\]\u\[\e[01;38;5;160m\]⚡\[\e[01;38;5;240m\]| \[\e[01;38;5;31m\]\w\[\e[01;38;5;240m\]\n↪        \[\e[01;38;5;28m\]\$ \[\033[00m\]'

# keyboard layouts
setxkbmap -layout us,ru -option grp:alt_shift_toggle

# primary aliases
alias shtdn='shutdown -h now'

# wp-script aliases
alias wpwp='wp-script'
alias wpwpi='wp-script info'
alias wpwpc='wp-script change'
alias wpwps='wp-script save'
alias wpwpus='wp-script unsave'
alias wpwpr='wp-script remove'

# fzf key-bindings and completion
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash
  # Ctrl + t to search files in the current directory
  # Ctrl + r to search command history.
  # Alt + c  finding and changing to a directory



# Initialize SSH_AUTH_SOCK and launch gpg-agent
#gpgconf --kill gpg-agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

#git aliases
alias gits='/usr/bin/git status'
alias gitc='/usr/bin/git commit =m '
alias gitp='/usr/bin/git push github main'
# dots: a bare git repository for some (added) home directory files
alias dots='/usr/bin/git --git-dir=$HOME/.dots.git/ --work-tree=$HOME'
alias dotss='/usr/bin/git --git-dir=$HOME/.dots.git/ --work-tree=$HOME status'
alias dotsc='/usr/bin/git --git-dir=$HOME/.dots.git/ --work-tree=$HOME commit -m '
alias dotsuc='/usr/bin/git --git-dir=$HOME/.dots.git/ --work-tree=$HOME commit -m "unspecified commit"'
alias dotsp='/usr/bin/git --git-dir=$HOME/.dots.git/ --work-tree=$HOME push github main'
alias dotsaa='gitaa dots'

# vim-iced (closure)
export PATH="~/.vim/plugged/vim-iced/bin/:$PATH"
