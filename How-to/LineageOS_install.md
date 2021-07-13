# Installing LinageOS on OnePlus 5

### adb and fastboot tools
```sh
mkdir ~/.adb-fastboot && cd ~/.adb-fastboot
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
export PATH="$HOME/.adb-fastboot/platform-tools:$PATH"
```

~/.bashrc
```sh
echo '# android brige tools' >> ~/.bashrc
echo 'if [ -d "$HOME/.adb-fastboot/platform-tools" ] ; then' >> ~/.bashrc
echo '  export PATH="$PATH:$HOME/adb-fastboot/platform-tools"' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
```

## udev rules for USB debugging Android devices
##### ( pemission to write to the plugged in device )
### Variant 1
##### add a udev rule so that the device will belong to a reasonable group,like 'plugdev', of which you are a member.
Make shure that you are the member of the group.
```sh
groups
```
Find "idVendor" and "idProduct"
Here, idVendor and idProduct come from the output of lsusb: 18d1:d002. 
```sh
lsusb
Bus 001 Device 008: ID 18d1:d002 Google Inc. OnePlus
```
Create a udev rules file, let’s say: /etc/udev/rules.d/51-android.rules
```sh
sudo bash <<"EOFF"
cat <<"EOF" >> /etc/udev/rules.d/51-android.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="d002", MODE="0660", GROUP="plugdev", SYMLINK+="android%n"
EOF
EOFF
```
P.S. Different modes, like fastboot or recovery, get assined with their own 'idProduct',
so add lines in '/etc/udev/rules.d/51-android.rules', replug the device, and check with:
```sh
adb devices
```
or
```sh
fastboot devices
```
### Variant 2
##### if you often work with differint devices.
Install uneversal udev rules:
```sh
git clone https://github.com/M0Rf30/android-udev-rules.git
cd android-udev-rules
cat README.md | more
```
### Files
TWRP : https://dl.twrp.me/cheeseburger/  
firmware : https://sourceforge.net/projects/cheeseburgerdumplings/files/16.0/cheeseburger/firmware/  
LineageOS : https://download.lineageos.org/cheeseburger  
Magisk : https://github.com/topjohnwu/Magisk  
### Unlocking the bootloader
- Enable developer options and USB debugging:
  - Settings-About. Tap on “Build number” till you are a developer.
  - Settings-Developer options. Check the “Android debugging” or “USB debugging” 
- Plug your device into your computer.
- On the computer: $ adb devices. 
- A dialog on your device: Check “always allow”, and choose “OK”.
- $ adb reboot bootloader
- Once the device is in fastboot mode: $ fastboot oem unlock
- If the device doesn’t automatically reboot, reboot it. It should now be unlocked
- Re-enable developer options and USB debugging.
###  custom recovery
```sh
adb reboot bootloader
fastboot flash recovery ~/Downloads/twrp-x.x.x-x-cheeseburger.img
```
### Installing LineageOS
- Reboot into recovery: With the device powered off, hold Volume Down + Power
- TWRP: Wipe, Format Data, swipe
- TWRP: Wipe, Advanced Wipe, Cache and System, swipe
- TWRP: Advanced, ADB Sideload, swipe
```sh
adb sideload ~/Downloads/lineage-x.x.x-nightly-cheeseburger-signed.zip
```
### Magisk
???

