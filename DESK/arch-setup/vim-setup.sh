#!/bin/bash

paru -S --noconfirm --needed curl vim xkb-switch

# SETTING-UP THE "PLUG" PLUGIN MANAGER AND PLUGINS:
#--------------------------------------------------
plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
vimrc_url="https://raw.githubusercontent.com/maxprio/dots/main/.vimrc"

# download plug.vim if not found
[ ! -f '~/.vim/autoload/plug.vim' ]\
    && curl -fLo ~/.vim/autoload/plug.vim --create-dirs "$plug_url"

# download config to a temp file
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak # just in case
curl -fLo ~/.vimrc.tmp "$vimrc_url"


# begin the config with the autocommand on enter.
# Run PlugInstall if there are missing plugins and quit
cat << 'EOF' > ~/.vimrc
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC | quitall
\| endif
EOF
# add the rest of the config
cat ~/.vimrc.tmp >> ~/.vimrc
# run vim
vim
# restore the original .vimrc
rm ~/.vimrc
mv ~/.vimrc.tmp  ~/.vimrc
