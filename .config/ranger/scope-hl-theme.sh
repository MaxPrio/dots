#!/bin/bash

HL_DIR=/usr/share/highlight
[ ! -d $HL_DIR ] && exit 1
SCOPE_SCRIPT=~/.config/ranger/scope.sh
[ ! -f $SCOPE_SCRIPT ] && exit 1

HLTHM="$HL_DIR/themes/$( ls $HL_DIR/themes/ | fzf )"
[ ! -f $HLTHM ] && exit 1

sed -i "s|highlight_theme=.*\.theme|highlight_theme=$HLTHM|g" $SCOPE_SCRIPT
