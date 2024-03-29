#!/bin/bash
pkgs_file="pkgs.txt"
[ -d $pkgs_file ]\
  || echo "error: no $pkgs_file."\
     && exit 1

ins-paru () {
sudo pacman -S --noconfirm --needed base-devel git

  [ ! d "~/.gitclone" ]\
    && mkgir -p "~/.gitclone"
  cd "~/.gitclone"
  git clone "https://aur.archlinux.org/paru.git"
  cd paru
  makepkg -si --noconfirm
}

fout-hash (){
# end the line in front of "#"
# remove empty lines and trailing spaces
# one WORD per line
  [ -z $1 ]\
    && src='-'\
    || src="$1"
sed -e 's/#.*$//;/^\s*$/d;s/\s\+$//;s/\s\+/\n/g' $src
}

sudo pacman -S --noconfirm --needed which
[ $( which paru ) ]\
  ||  ins-paru

cat "$pkgs_file" | fout-hash |\
  while read pkgname
    do
      echo "INSTALLING: ${pkgname}"
      echo "executing: paru -S --noconfirm --needed ${pkgname}"
      paru -S --noconfirm --needed ${pkgname}
    done

