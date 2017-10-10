#!/usr/bin/env bash

LEFT=1
RIGHT=3
TOP=1
BOTTOM=3

position() {
   oldstty=$(stty -g)
   stty raw -echo min 0
   echo -en "\033[6n" > /dev/tty
   IFS=';' read -r -d R -a pos
   stty $oldstty
   # change from one-based to zero based so they work with: tput cup $row $col
   row=$((${pos[0]:2} - 1))    # strip off the esc-[
   col=$((${pos[1]} - 1))
   echo "$row,$col"
}

row() {
   a=`position`
   echo ${a%%,*}
}

col() {
   a=`position`
   echo ${a##*,}
}

up() {
   [[ `row` > $LEFT ]] && tput cuu 1
}

down() {
   [[ `row` < $RIGHT ]] && tput cud 1
}

left() {
   [[ `col` > $TOP ]] && tput cub 1
}

right() {
   [[ `col` < $BOTTOM ]] && tput cuf 1
}

clear
echo "#####"
echo "#   #"
echo "#   #"
echo "#   #"
echo "#####"
while IFS= read -s -n 1 char
do
   case $char in
      w) up ;;
      s) down ;;
      a) left ;;
      d) right ;;
      o) echo -n o ;;
      x) echo -n x ;;
      q) exit 0 ;;
   esac
done
