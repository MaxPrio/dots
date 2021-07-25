#!/bin/bash

HIGHT=$1
ST=start
TG=target
SP=spare
MI=0
INDX=0

FFF=$ST
ch-fff () {
  if [ $FFF == $TAIL ]
    then
      FFF=$HEAD
      true
    else
      false
  fi
}

number-of-moves () {
 local hight moves 
 hight=$1
 [ -z $2 ] && moves=0 || moves=$2
 if [ $hight -gt 0 ]
   then
     moves=$((moves*2+1))
     ((--hight))
     echo $( number-of-moves $hight $moves)
   else
     echo $moves
 fi
}

first-move () {
  TAIL=$ST
  if [ $((HIGHT%2)) -eq 0 ]
    then
      HEAD=$SP
      SPEAR=$TG
    else
      HEAD=$TG
      SPEAR=$SP
  fi
}

flip-two-vars () {
  local temp
  eval temp=\$"$1"
  eval $1=\$"$2"
  eval $2=\$"temp"
}

next-move () {
  ((++MI))
  [ $MI -gt 8 ] && MI=1
  case $MI in
    1|5|7 )
      flip-two-vars HEAD SPEAR
      ;;
    2|6|8 )
      flip-two-vars TAIL SPEAR
      ;;
    3|4 )
      flip-two-vars HEAD SPEAR
      flip-two-vars HEAD TAIL
      ;;
  esac
}

print-move () {
  #((++INDX))
  #echo -n "$INDX   $TAIL→$HEAD"
     
  #echo -n '  '
  case "$TAIL$HEAD" in
    $ST$TG )
      echo -ne '(→)'\\r
      ;;
    $ST$SP )
      echo -ne '(↗)'\\r
      ;;
    $TG$ST )
      echo -ne '(←)'\\r
      ;;
    $TG$SP )
      echo -ne '(↖)'\\r
      ;;
    $SP$ST )
      echo -ne '(↙)'\\r
      ;;
    $SP$TG )
      echo -ne '(↘)'\\r
      ;;
    * )
      echo -ne "No image for this move."\\r
  esac
  sleep 1
}

# Main
#------
LEFT_MOVES=$(number-of-moves $HIGHT )
echo "Hight - $HIGHT. Number of moves - $LEFT_MOVES."
echo "List of moves:"

first-move $HIGHT
ch-fff && print-move
((--LEFT_MOVES))

while [ $LEFT_MOVES -gt 0 ]
  do
    next-move
    ch-fff && print-move
    ((--LEFT_MOVES))
done

