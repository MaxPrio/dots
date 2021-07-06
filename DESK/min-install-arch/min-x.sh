#!/bin/bash

# alsa
sudo pacman -S alsa-utils --noconfirm

amixer sset Master unmute
amixer sset Master 90%
amixer sset Front unmute
amixer sset Front 90%
amixer sset Headphone unmute
amixer sset Headphone 90%

speaker-test -c 2

# xorg
sudo pacman -S xorg-server xorg-xinit --noconfirm --needed

sudo pacman -S ttf-dejavu ttf-liberation ttf-linux-libertine noto-fonts terminus-font ttf-inconsolata --noconfirm --needed
#mkdir ~/.config/fontconfig
#cp ./files/fonts.conf ~/.config/fontconfig/

sudo pacman -S openbox feh rxvt-unicode fzf xsel highlight ranger rofi --noconfirm --needed

#YAY
mkdir Download
cd Download
git clone https://aur.archlinux.org/yay.git
sudo chown -R maxprio:users ./yay
cd yay
makepkg -si

#yay -Ss <package-name-to-search>
#yay -S <package-name-to-install>

# vim
yay -S xkb-switch
#sudo pacman -S gvim --noconfirm --needed

# install vimplug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# install plugins
vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"

