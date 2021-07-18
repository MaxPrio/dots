#!/bin/bash

# CONFIG VARS
#===============================
# Sync time
# Reflector
    #MIRROR_COUNTRIES='Russia'
    MIRROR_COUNTRIES='German'
# Console font
    CFONT_PAC='terminus-font'
    CFONT='ter-v24n'
    KEYMAP='ruwin_alt_sh-UTF-8'
# Enter passwords
# Partitionning
    TGTDEV='/dev/sda'
    BOOTSZ='512M'
# Crypt: setup and open
    CRYPT_DEV="${TGTDEV}2"
    CRYPT_PSWD='' # leave empty to set with 'input-val-dblcheck' function
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
    ROOT_PSWD='' # leave empty to set with 'input-val-dblcheck' function
    LUSER=maxprio
    LUSER_PSWD='' # leave empty to set with 'input-val-dblcheck' function
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
#.Umount & reboot

# GENETAL FUNCTIONS
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

# FUNCTIONS
#===============================
# Sync time
sync-time () {
  echo "Syncing time. . ."
  timedatectl set-ntp true
  echo -n 'Date and time: '
  date
}
# Reflector
set-mirrors () {
  echo "Creating mirror list with 'reflector' for '$MIRROR_COUNTRIES'. . ." 
  reflector --country $MIRROR_COUNTRIES --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  echo "Updating pacman sources. . ." 
  pacman -Syy
}
# Console font
set-consolefont () {
  echo "Setting up console font."
  echo "Installing '$CFONT_PAC'. . ."
  pacman -S $CFONT_PAC --no-confirm
  echo "Setting '$CFONT' for console. . .."
  setfont $CFONT
  echo "Loading keymap, '$KEMAP'. . .."
  loadkeys $KEYMAP 
}
# Enter passwords
enter-passwords () {
[ -z $CRYPT_PSWD ] && input-val-dblcheck 'LUKS password' 'CRYPT_PSWD'
[ -z $ROOT_PSWD ] && input-val-dblcheck 'Password for the superuser' 'ROOT_PSWD'
[ -z $LUSER_PSWD ] && input-val-dblcheck "Password for $LUSER" 'LUSER_PSWD'
}
# Partitionning
format-disk () {
echo "Partitioning the '' with fdisk. . ."
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

echo "RESULTING PARTITION TABLE ON '${TGTDEV}':"
echo ''
echo -e "p\nq\n" | sudo fdisk /dev/sda 2>&1 | grep "^Device\|^/dev"
echo ''
}
# Crypt: setup and open
set-crypt () {
  echo "Setting up LUKS partition on '$CRYPT_DEV'. . ."
  if [ -z $CRYPT_PSWD ]
    then
      echo "The password for LUKS is not set. EXIT." && exit 1
    else
      echo -n "$CRYPT_PSWD" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 $CRYPT_DEV
  fi
}
crypt-open () {
  echo "Openning a LUKS partition on '$CRYPT_DEV' as '/dev/mapper/$CRYPT_DEV_NAME'. . ."
  if [ -z $CRYPT_PSWD ]
    then
      echo "The password for LUKS is not set. EXIT." && exit 1
    else
      echo -n "$CRYPT_PSWD" | cryptsetup --key-file=- open $CRYPT_DEV $CRYPT_DEV_NAME
      sleep 5
  fi
}
# LVM
set-lvm () {
  echo "Setting up LVM:"
  echo "LVM: creating phisical voulume on '/dev/mapper/$CRYPT_DEV_NAME'. . ."
  pvcreate "/dev/mapper/$CRYPT_DEV_NAME"
  echo "LVM: creating voulume group 'lv0' on '/dev/mapper/$CRYPT_DEV_NAME'. . ."
  vgcreate lvg0 "/dev/mapper/$CRYPT_DEV_NAME"
  echo "LVM: creating logical voulume 'lv_root' ($ROOTSZ). . ."
  lvcreate -L $ROOTSZ lvg0 -n lv_root
  echo "LVM: creating logical voulume 'lv_home' ($ROOTSZ). . ."
  lvcreate -l $HOMESZ lvg0 -n lv_home
  modprobe dm_mod
  vgscan
  vgchange -ay
  echo 'lsblk:'
  lsblk
  echo ''
}
# Make fs
make-fsms () {
  echo 'Creating filesystems:'
  $MKFS_BOOT_CMD ${TGTDEV}1
  $MKFS_ROOT_CMD /dev/lvg0/lv_root
  $MKFS_HOME_CMD /dev/lvg0/lv_home
}
# Mount
mnt-mount () {
  echo 'Mounting filesystems. . .'
  mount /dev/lvg0/lv_root ${CHROOT_ROOT}
  mkdir ${CHROOT_ROOT}/boot
  mount ${TGTDEV}1 ${CHROOT_ROOT}/boot
  mkdir ${CHROOT_ROOT}/home
  mount /dev/lvg0/lv_home ${CHROOT_ROOT}/home
  echo 'lsblk:'
  lsblk
  echo ''
}
# Base pacstrap
base-pacstrap () {
  echo "Installing base system (base linux-tts) to '${CHROOT_ROOT}' with pacstrap . . ."
  pacstrap -i ${CHROOT_ROOT} base linux-lts --noconfirm
}
# Make fstab
mk-fstab () {
  echo "Generating fstab to  '${CHROOT_ROOT}/etc/fstab'. . ."
  genfstab -pU ${CHROOT_ROOT} >> ${CHROOT_ROOT}/etc/fstab
  echo "${CHROOT_ROOT}/etc/fstab:"
  echo "-------------------------"
  cat ${CHROOT_ROOT}/etc/fstab
  echo ''
  
}
# Chroot Mirrors
chroot-setup-mirrors () {
  echo 'Copying the mirrorlist over. . .'
  cp --parents /etc/pacman.d/mirrorlist ${CHROOT_ROOT}
  echo "Updating the pacman sources. . ."
  arch-chroot ${CHROOT_ROOT} pacman -Syy
}
# min install
chroot-install-minimum () {
  echo "Installing additional base packiges (base-devel linux-firmware linux-lts-headers man). . ."
  arch-chroot ${CHROOT_ROOT} pacman -S base-devel linux-firmware linux-lts-headers man -font --noconfirm
}
# Kernel
chroot-fix-kernel () {
  echo "Adding '$HOOKS_TOADD' hooks, to the core config file. . ."
  sed -i "/^HOOKS=/ s/$INFRONTOF_HOOK/$HOOKS_TOADD\ $INFRONTOF_HOOK/" ${CHROOT_ROOT}/etc/mkinitcpio.conf
  echo "updated hooks line in the core config file:"
  cat ${CHROOT_ROOT}/etc/mkinitcpio.conf | grep ^HOOKS
  echo ''
  echo "Installing 'lvm2' (and recompiling the core). . ."
  arch-chroot ${CHROOT_ROOT} pacman -S lvm2 --noconfirm
  # arch-chroot ${CHROOT_ROOT} mkinitcpio -p linux-lts
}

# Grub
chroot-setup-grub () {
  echo 'SETTING UP GRUB:'
  echo "Installing: $CPU_UCODE grub os-prober dosfstools mtools. . ."
  arch-chroot ${CHROOT_ROOT} pacman -S $CPU_UCODE grub os-prober dosfstools mtools --noconfirm
  echo "Installing grub onto '${TGTDEV}'. . ."
  arch-chroot ${CHROOT_ROOT} grub-install --target=i386-pc --recheck ${TGTDEV}
  echo "Copying english locale, for grub massages. . ."
  cp ${CHROOT_ROOT}/usr/share/locale/en\@quot/LC_MESSAGES/grub.mo ${CHROOT_ROOT}/boot/grub/locale/en.mo

  echo "Fixing grub-mkconfig config:"
  CRYPT_ID=$(blkid ${TGTDEV}2 | sed 's/^.*\ UUID=\"\([^\"]*\)\".*$/\1/')
  exho "The LUKS partition (${TGTDEV}) id: $CRYPT_ID"
  sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/quiet/cryptdevice=UUID=$CRYPT_ID\:cryptroot\:allow-discards\ text/" ${CHROOT_ROOT}/etc/default/grub
  echo "The fixed line in grub-mkconfig config file:"
  cat ${CHROOT_ROOT}/etc/default/grub | grep "^GRUB_CMDLINE_LINUX_DEFAULT"
  #sed -i '/GRUB_ENABLE_CRYPTODISK/ s/^.*$/GRUB_ENABLE_CRYPTODISK=y/' ${CHROOT_ROOT}/etc/default/grub
  echo 'Running grub-mkconfig. . .'
  arch-chroot ${CHROOT_ROOT} grub-mkconfig -o /boot/grub/grub.cfg
}

# Swapfile
chroot-setup-swap () {
  echo "Allockating swapfile '${CHROOT_ROOT}${SWAPFL}' ($SWAPSZ) with dd. . ."
  dd if=/dev/zero of=${CHROOT_ROOT}${SWAPFL} bs=1M count=$SWAPSZ status=progress
  echo "Setting permitions to '${CHROOT_ROOT}${SWAPFL}' (chmod 600). . ."
  chmod 600 ${CHROOT_ROOT}$SWAPFL
  echo "Executing mkswap, on '${SWAPFL}'. . ."
  arch-chroot ${CHROOT_ROOT} mkswap $SWAPFL
    
  echo "Fixing fstab, for swapfile. . ."
  cat >> ${CHROOT_ROOT}/etc/fstab <<EOF

# swapfile
$SWAPFL none swap defaults 0 0
EOF
  echo "${CHROOT_ROOT}/etc/fstab"
  echo "------------------------"
  cat ${CHROOT_ROOT}/etc/fstab
}

# Trim
chroot-setup-fstrim () {
    if [ "$TRIM_DEV" == "true" ]
      then
        echo "Fixing fstab, for fstrime.service. . ."
        sed -i 's/relatime/noatime/' ${CHROOT_ROOT}/etc/fstab \
        echo "${CHROOT_ROOT}/etc/fstab"
        echo "------------------------"
        cat ${CHROOT_ROOT}/etc/fstab
        echo "Enabling fstrim.timer. . ."
        arch-chroot ${CHROOT_ROOT} systemctl enable fstrim.timer
    fi
}
# User
chroot-setup-users () {
  echo "SETTING UP USERS."
  if [ -z $ROOT_PSWD ]
    then
      echo "NO ROOT password is provided. EXIT..." && exit 1
    else
      echo "Setting uo root password. . ."
      printf "$ROOT_PSWD\n$ROOT_PSWD" | arch-chroot ${CHROOT_ROOT} passwd
  fi
  if [ -z $LUSER ]
    then
      echo "NO USER name is provided"
    else
      echo "Creating $LUSER user account. . ."
      arch-chroot ${CHROOT_ROOT} useradd -m -G wheel -s /bin/bash $LUSER
      if [ -z $LUSER_PSWD ]
        then
          echo "NO PASSWORD for $LUSER"
        else
          echo "Setting up $LUSER password. . ."
          printf "$LUSER_PSWD\n$LUSER_PSWD" | arch-chroot ${CHROOT_ROOT} passwd $LUSER
      fi
  fi

  echo ''
  echo "Fixing sudoers file. . ."
  sed -i '/^#.*wheel.*)\ ALL/ s/^#//' ${CHROOT_ROOT}/etc/sudoers
  sed -i '/^#.*wheel.*NOPASSWD/ s/^#//;s/NOPASSWD.*$/NOPASSWD: \/usr\/bin\/shutdown/' ${CHROOT_ROOT}/etc/sudoers
  echo "Fixed lines:"
  cat ${CHROOT_ROOT}/etc/sudoers | grep "^.*wheel.*)\ ALL"
  cat ${CHROOT_ROOT}/etc/sudoers | grep "^.*wheel.*NOPASSWD"
}

# Network
chroot-setup-network () {
  echo "NETWORK:"
  echo "Installing network base packs:(networkmanager netctl). . .  "
  arch-chroot ${CHROOT_ROOT} pacman -S networkmanager netctl --noconfirm
  echo "Enabling networkmanager. . .  "
  arch-chroot ${CHROOT_ROOT} systemctl enable NetworkManager
  echo "NetworkManager status:"
  arch-chroot ${CHROOT_ROOT} systemctl status NetworkManager
  echo "$HOSTNAME" > ${CHROOT_ROOT}/etc/hostname
  echo "${CHROOT_ROOT}/etc/hostname:"
  echo "-------------------"
  cat ${CHROOT_ROOT}/etc/hostname
  echo ''
  cat > ${CHROOT_ROOT}/etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.$LDOM $HOSTNAME
EOF
  echo "${CHROOT_ROOT}/etc/hosts:"
  echo "-------------------"
  cat ${CHROOT_ROOT}/etc/hosts
  echo ''
}
# Localisation
chroot-setuo-time () {
  echo "Setting timezone to '$TIMEZONE'. . ."
  arch-chroot ${CHROOT_ROOT} ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  echo "Setting hwclock. . ."
  arch-chroot ${CHROOT_ROOT} hwclock --systohc --utc
  echo "Date and time:"
  date
}
chroot-setup-locale () {
  echo "Setting up locales:"
  echo "Uncommenting needed lines in locale_gen file. . ."
  #sed -i "/^#$LOCALES/  s/^#//" ${CHROOT_ROOT}/etc/locale.gen
  while read lcl
    do
      echo "uncommenting '\#$lcl' line. . ."
      sed -i "/^#$lcl/  s/^#//" ${CHROOT_ROOT}/etc/locale.gen
    done < <( echo -n $LOCALES | tr ";" "\n" )
  echo "Uncommented lines in locale_gen file:"
  cat ${CHROOT_ROOT}/etc/locale.gen | grep ^[^#]
  echo "Generating locales. . ."
  arch-chroot ${CHROOT_ROOT} locale-gen

  echo "Setting up language. . ."
  echo "LANG=$LANG" > ${CHROOT_ROOT}/etc/locale.conf
  echo "${CHROOT_ROOT}/etc/locale.conf:"
  cat ${CHROOT_ROOT}/etc/locale.conf
}
chroot-setup-keyboard () {
  echo "Installing '$CFONT_PAC'. . ."
  arch-chroot ${CHROOT_ROOT} pacman -S $CFONT_PAC --noconfirm
  echo "Setting up keyboard map '$KEYMAP'. . ."
  echo "KEYMAP=$KEYMAP" >> ${CHROOT_ROOT}/etc/vconsole.conf
  echo "FONT=$CFONT" >> ${CHROOT_ROOT}/etc/vconsole.conf
  echo "${CHROOT_ROOT}/etc/vconsole.conf:"
  cat ${CHROOT_ROOT}/etc/vconsole.conf
}
# 11.Umount & reboot
umount-and-reboot () {
  echo "Unmounting. . ."
  umount -R ${CHROOT_ROOT}
  echo "Rebooting. . ."
  reboot
}

#===========================

# Sync time
sync-time
# Reflector
set-mirrors
# Console font
set-consolefont
# Enter passwords
enter-passwords
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
