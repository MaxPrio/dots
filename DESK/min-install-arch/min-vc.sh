#!/bin/bash

# CHROOT
#========
pacman -S reflector
reflector --country Russia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy
pacman -S base-devel linux-firmware linux-headers networkmanager netctl openssh git man terminus-font vim --noconfirm

systemctl enable NetworkManager
systemctl enable sshd

echo 'maxprio-ws1' > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	maxprio-ws1.prionet	maxprio-ws1
EOF

# mkinitcpio
#===========
sed -i '/^HOOKS=/ s/filesystems/encrypt\ lvm2\ filesystems/' /etc/mkinitcpio.conf
pacman -S lvm2 --noconfirm
#mkinitcpio -p linux

# swapfile 8G 
#==============
#fallocate -l 8192M /swapfile
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
cat >> /etc/fstab <<EOF

# /swapfile
/swapfile none swap defaults 0 0
EOF

# Localisation
#==============
ln -sf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
hwclock --systohc --utc

sed -i '/^#en_US\.UTF-8\ UTF-8/  s/^#//' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

localectl set-keymap --no-convert ruwin_alt_sh-UTF-8
localectl status
echo 'KEYMAP=ruwin_alt_sh-UTF-8' >> /etc/vconsole.conf
pacman -S terminus-font --noconfirm
echo 'FONT=ter-v24n' >> /etc/vconsole.conf

# User
#=====
passwd
useradd -m -g users -G wheel maxprio
passwd maxprio
chown -R maxprio:users /home/maxprio

sed -i '/^#.*wheel.*)\ ALL/ s/^#//' /etc/sudoers
sed -i '/^#.*wheel.*NOPASSWD/ s/^#//;s/NOPASSWD.*$/NOPASSWD: \/usr\/bin\/poweroff, \/usr\/bin\/reboot, \/usr\/bin\/shutdown/' /etc/sudoers

# GRUB2
#======
#pacman -S amd-ucode --noconfirm
pacman -S intel-ucode --noconfirm
pacman -S grub os-prober dosfstools mtools --noconfirm

grub-install --target=i386-pc --recheck /dev/sda
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

CRYPT_ID=$(blkid /dev/sda2 | sed 's/^.*\ UUID=\"\([^\"]*\)\".*$/\1/')
sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/quiet/cryptdevice=UUID=$CRYPT_ID\:cryptlvm\:allow-discards\ text/" /etc/default/grub
#sed -i '/GRUB_ENABLE_CRYPTODISK/ s/^.*$/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# exit
#===========
swapoff -a
exit
