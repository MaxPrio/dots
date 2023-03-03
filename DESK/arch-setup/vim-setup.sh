#!/bin/bash

echo -ne '
SETTING-UP VIM.
---------------'
# just in case
pacman -S --noconfirm --needed curl vim
paru -S --noconfirm --needed xkb-switch

# a finction,to cut out a function
cut_core () {
# filters out the lines, outside the given pattern lines ( $1 & $2 ).
    sed -n "/$1/,\$p" - \
      | sed  "/$2/q" -
}

echo -ne '
setting-up the plugin manager "vim-plug" 
-----------------------------------------'
plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
vimrc_url="https://raw.githubusercontent.com/maxprio/dots/main/.vimrc"

# if not found, download plug.vim 
[ ! -f '~/.vim/autoload/plug.vim' ]\
    && curl -fLo ~/.vim/autoload/plug.vim --create-dirs "$plug_url"

echo -ne '
Done!
-----'

echo -ne '
setting-up plugins.
-------------------'
echo -ne 'creating the temp config...  '
# just in case
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak
# begin the local config with the autocommand on enter:
# "if there are missing plugins run PlugInstall and then quit"
cat << 'EOF' > ~/.vimrc
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC | quitall
\| endif
EOF
# download the plug function from the config on github.
# and append to the local config.
curl -s "$vimrc_url"\
  | cut_core '.*call\ plug#begin.*' '.*call\ plug#end.*'\
  | sed '/^\s.*\"/d'\
  >> ~/.vimrc
echo -ne ' Done!
'
# run vim
echo -ne '
running vim to insall the plugins...'
vim

# clean up
echo -ne '
cleaning up...  '
rm ~/.vimrc
[ -f ~/.vimrc.buk ]\
  && mv ~/.vimrc.buk  ~/.vimrc

echo -ne ' Done!
'
