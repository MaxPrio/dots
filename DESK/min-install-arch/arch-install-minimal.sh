#!/bin/bash

#===============================
input-val-dblcheck () {
    local ismatch
    echo "Setting $1 . . ."
    ismatch="false"
    while [ "$ismatch" != "true" ]; do
        read -sp "     (input 1) $1: " input1
        echo ""
        read -sp "(double check) $1: " input2
        echo ""
        if [ "$input1" == "$input2" ]
            then
                if [ -z $input1 ]
                    then
                        echo "[ ER ]  $1 can not be empty. Try again."
                    else
                        ismatch="true"
                        echo "[ OK ]  $1 is set."
                    fi
            else
                echo "[ ER ]  Not a match. Try again."
            fi
    done

    eval $2=$input1
}
#===============================

# Reflector
    MIRROR_COUNTRIES='Russia'
# Console font
    CFONT_PAC='terminus-font'
    CFONT='ter-v24n'
# Partitionning
    TGTDEV='/dev/sda'
    BOOTSZ='512M'
# Crypt: setup and open
    CRYPT_DEV="${TGTDEV}2"
    input-val-dblcheck 'LUKS password' 'CRYPT_PSWD'
    CRYPT_DEV_NAME='cryptroot'
# LVM
    ROOTSZ='27G'
    HOMESZ='100%FREE'
# Make fs
    MKFS_BOOT_CMD='mkfs.ext4'
    MKFS_ROOT_CMD="$MKFS_BOOT_CMD"
    MKFS_HOME_CMD="$MKFS_BOOT_CMD"
#  Mount
    CHROOT_ROOT='/mnt'
# Base pacstrap
# Make fstab
# Chroot Mirrors
# min install
# Kernel
    HOOKS_TOADD='encrypt lvm2'
    INFRONTOF_HOOK='filesystems'
# Grub
    CPU_UCODE='intel-ucode'
    #CPU_UCODE='amd-ucode'
# Swapfile
    SWAPFL='/swapfile'
    SWAPSZ=4096
# Trim
    TRIM_DEV='true'
# User
    input-val-dblcheck 'Password for the superuser' 'ROOT_PSWD'
    LUSER=maxprio
    input-val-dblcheck "Password for $LUSER" 'LUSER_PSWD'
# Network
# Hosts
    HOSTNAME='maxprio-ws1'
    LDOM='prionet'
# Localisation
    TIMEZONE='Asia/Yekaterinburg'
    LOCALES='en_US.UTF-8 UTF-8'
    #LOCALES='en_US.UTF-8 UTF-8;ru_RU.UTF-8 UTF-8'
    LANG='en_US.UTF-8'
# Console kbd
    KEYMAP='ruwin_alt_sh-UTF-8'
    CFONT='ter-v24n'
#.Umount & reboot

#===============================

# Reflector
set-mirrors () {
    reflector --country $MIRROR_COUNTRIES --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    pacman -Syy
}
# Console font
set-consolefont () {
pacman -S $CFONT_PAC --no-confirm
setfont $CFONT
}
# Partitionning
format-disk () {
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +${BOOTSZ} # boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF
}
# Crypt: setup and open
set-crypt () {
    echo -n "$CRYPT_PSWD" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 $CRYPT_DEV
}
crypt-open () {
        echo -n "$CRYPT_PSWD" | cryptsetup --key-file=- open $CRYPT_DEV $CRYPT_DEV_NAME
        sleep 5
}
# LVM
set-lvm () {
pvcreate "/dev/mapper/$CRYPT_DEV_NAME"
vgcreate lvg0 "/dev/mapper/$CRYPT_DEV_NAME"
lvcreate -L $ROOTSZ lvg0 -n lv_root
lvcreate -l $HOMESZ lvg0 -n lv_home
modprobe dm_mod
vgscan
vgchange -ay
}
# Make fs
make-fsms () {
$MKFS_BOOT_CMD ${TGTDEV}1
$MKFS_ROOT_CMD /dev/lvg0/lv_root
$MKFS_HOME_CMD /dev/lvg0/lv_home
}
# Mount
mnt-mount () {
mount /dev/lvg0/lv_root ${CHROOT_ROOT}
mkdir ${CHROOT_ROOT}/boot
mount ${TGTDEV}1 ${CHROOT_ROOT}/boot
mkdir ${CHROOT_ROOT}/home
mount /dev/lvg0/lv_home ${CHROOT_ROOT}/home
}
# Base pacstrap
base-pacstrap () {
pacstrap -i ${CHROOT_ROOT} base linux --noconfirm
}
# Make fstab
mk-fstab () {
genfstab -pU ${CHROOT_ROOT} >> ${CHROOT_ROOT}/etc/fstab
}
# Chroot Mirrors
chroot-setup-mirrors () {
    cp --parents /etc/pacman.d/mirrorlist ${CHROOT_ROOT}
    arch-chroot ${CHROOT_ROOT} pacman -Syy
}
# min install
chroot-install-minimum () {
    arch-chroot ${CHROOT_ROOT} pacman -S base-devel linux-firmware linux-headers networkmanager netctl man terminus-font --noconfirm
}
# Kernel
chroot-fix-kernel () {
    sed -i "/^HOOKS=/ s/$INFRONTOF_HOOK/$HOOKS_TOADD\ $INFRONTOF_HOOK/" ${CHROOT_ROOT}/etc/mkinitcpio.conf
    arch-chroot ${CHROOT_ROOT} pacman -S lvm2 --noconfirm
    # arch-chroot ${CHROOT_ROOT} mkinitcpio -p linux
}

# Grub
chroot-setup-grub () {
    arch-chroot ${CHROOT_ROOT} pacman -S $CPU_UCODE grub os-prober dosfstools mtools --noconfirm
    arch-chroot ${CHROOT_ROOT} grub-install --target=i386-pc --recheck ${TGTDEV}
    cp ${CHROOT_ROOT}/usr/share/locale/en\@quot/LC_MESSAGES/grub.mo ${CHROOT_ROOT}/boot/grub/locale/en.mo

    CRYPT_ID=$(blkid ${TGTDEV}2 | sed 's/^.*\ UUID=\"\([^\"]*\)\".*$/\1/')
    sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/quiet/cryptdevice=UUID=$CRYPT_ID\:cryptroot\:allow-discards\ text/" /etc/default/grub
    #sed -i '/GRUB_ENABLE_CRYPTODISK/ s/^.*$/GRUB_ENABLE_CRYPTODISK=y/' ${CHROOT_ROOT}/etc/default/grub
    arch-chroot ${CHROOT_ROOT} grub-mkconfig -o /boot/grub/grub.cfg
}

# Swapfile
chroot-setup-swap () {
    dd if=/dev/zero of=${CHROOT_ROOT}${SWAPFL} bs=1M count=$SWAPSZ status=progress
    chmod 600 ${CHROOT_ROOT}$SWAPFL
    arch-chroot ${CHROOT_ROOT} mkswap $SWAPFL
    
cat >> ${CHROOT_ROOT}/etc/fstab <<EOF

# swapfile
$SWAPFL none swap defaults 0 0
EOF
}

# Trim
chroot-setup-fstrim () {
    [ "$TRIM_DEV" == "true" ] \
        && sed -i 's/relatime/noatime/' ${CHROOT_ROOT}/etc/fstab \
        && arch-chroot ${CHROOT_ROOT} systemctl enable fstrim.timer
}
# User
chroot-setup-users () {
    ROOT_PSWD=$( input-val-dblcheck "password for root" )
    LUSER_PSWD=$( input-val-dblcheck "password for $LUSER" )
    printf "$ROOT_PSWD\n$ROOT_PSWD" | arch-chroot ${CHROOT_ROOT} passwd
    arch-chroot ${CHROOT_ROOT} useradd -m -G wheel -s /bin/bash $LUSER
    printf "$LUSER_PSWD\n$LUSER_PSWD" | arch-chroot ${CHROOT_ROOT} passwd $LUSER

    sed -i '/^#.*wheel.*)\ ALL/ s/^#//' ${CHROOT_ROOT}/etc/sudoers
    sed -i '/^#.*wheel.*NOPASSWD/ s/^#//;s/NOPASSWD.*$/NOPASSWD: \/usr\/bin\/shutdown/' ${CHROOT_ROOT}/etc/sudoers
}

# Network
chroot-setup-network () {
    arch-chroot ${CHROOT_ROOT} systemctl enable NetworkManager

    echo "$HOSTNAME" > ${CHROOT_ROOT}/etc/hostname

cat > ${CHROOT_ROOT}/etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.$LDOM $HOSTNAME
EOF
}
# Localisation
chroot-setuo-time () {
    arch-chroot ${CHROOT_ROOT} ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    arch-chroot ${CHROOT_ROOT} hwclock --systohc --utc
}
chroot-setup-locale () {
    sed -i "/^#$LOCALES/  s/^#//" ${CHROOT_ROOT}/etc/locale.gen
    #while read lcl
    #    do
    #        sed -i "/^#$lcl/  s/^#//" ${CHROOT_ROOT}/etc/locale.gen
    #    done < <( echo -n $LOCALES | tr ";" "\n" )

    arch-chroot ${CHROOT_ROOT} locale-gen

    echo "LANG=$LANG" > ${CHROOT_ROOT}/etc/locale.conf
}
chroot-setup-keyboard () {
    echo "KEYMAP=$KEYMAP" >> ${CHROOT_ROOT}/etc/vconsole.conf
    echo "FONT=$CFONT" >> ${CHROOT_ROOT}/etc/vconsole.conf
    arch-chroot ${CHROOT_ROOT} localectl set-keymap --no-convert $KEYMAP
}
# 11.Umount & reboot
umount-and-reboot () {
umount -R ${CHROOT_ROOT}
reboot
}

#===========================

timedatectl set-ntp true
# Reflector
set-mirrors
# Console font
set-consolefont
# Partitionning
format-disk
# Cryptsetup
set-crypt
crypt-open
# LVM
set-lvm
# Make fs
make-fsms
#  Mount
mnt-mount
# Base pacstrap
base-pacstrap
# Make fstab
mk-fstab
# Chroot Mirrors
chroot-setup-mirrors
# min install
chroot-install-minimum
# Kernel
chroot-fix-kernel
# Grub
chroot-setup-grub
# Swapfile
chroot-setup-swap 
# Trim
chroot-setup-fstrim 
# User
chroot-setup-users
# Network
chroot-setup-network
# Localisation
chroot-setuo-time
chroot-setup-locale
chroot-setup-keyboard
# Umount & reboot
umount-and-reboot
