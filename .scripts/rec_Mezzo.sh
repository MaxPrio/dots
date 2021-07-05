#!/bin/bash
#REC_FOLDER='/home/maxprio/Videos/recs'
REC_FOLDER='/mnt/data1/shared/recs'
TMSTMP=$(date "+%d.%m.%Y-%H.%M.%S")
ffmpeg -i udp://@239.255.2.142:1234 -t $1':00.0' -c copy $REC_FOLDER/$TMSTMP'_'$2.ts
