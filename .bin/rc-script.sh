#!/bin/bash

# wallpaper restore
[[ ! -f ~/.wallpaper ]] \
    && ln -sf ~/.config/default-wallpaper.jpg ~/.wallpaper
feh --no-fehbg --bg-fill ~/.wallpaper

# urvt settings
xrdb -merge ~/.Xresources

# sound
#[[ -f ~/.config/alsamixer.state ]] \
#    && alsactl --file ~/.config/alsamixer.state restore

# DISPLAY and XAUTHORITY environment variables
# (for X apps executed by systemd.serveces)
#systemctl --user import-environment DISPLAY PATH XAUTHORITY
#if command -v dbus-update-activation-environment >/dev/null 2>&1; then
#    dbus-update-activation-environment DISPLAY XAUTHORITY
#fi
