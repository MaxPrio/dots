#!/bin/bash

youtube-dl \
    -f 22 \
    --playlist-start $2 \
    --playlist-end $3 \
    --autonumber-start $2 \
    --write-sub --embed-subs --sub-lang en \
    -o "$4%(autonumber)s-%(title)s.mp4" \
    $1
