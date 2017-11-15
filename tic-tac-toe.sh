#!/usr/bin/env bash

SIZE=3
LEFT=1
RIGHT=$(($LEFT + $SIZE - 1))
TOP=1
BOTTOM=$(($TOP + $SIZE - 1))

declare -A field
current_turn=x

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

insert() {
   row=`row`
   col=`col`
   field[$row, $col]=$@
   echo -n $@
   left
}

check_winner() {
   for ((i=$TOP; i <= $BOTTOM; i++)); do
      first=${field[$i, $LEFT]}
      all_same=1
      for ((j=$LEFT; j <= $RIGHT; j++)); do
         current=${field[$i, $j]}
         if [[ $current != $first ]]; then
            all_same=0
            break
         fi
      done
      if [[ $all_same != 0 && $first ]]; then
         clear
         echo "Winner $first"
         exit 0
      fi
   done

   for ((i=$LEFT; i <= $RIGHT; i++)); do
      first=${field[$LEFT, $i]}
      all_same=1
      for ((j=$TOP; j <= $BOTTOM; j++)); do
         current=${field[$j, $i]}
         if [[ $current != $first ]]; then
            all_same=0
            break
         fi
      done
      if [[ $all_same != 0 && $first ]]; then
         clear
         echo "Winner $first"
         exit 0
      fi
   done

   first=${field[$LEFT, $TOP]}
   all_same=1
   for ((s=0; s < $SIZE; s++)); do
      i=$(($TOP + $s))
      j=$(($LEFT + $s))
      current=${field[$i, $j]}
      if [[ $current != $first ]]; then
         all_same=0
         break
      fi
   done
   if [[ $all_same != 0 && $first ]]; then
      clear
      echo "Winner $first"
      exit 0
   fi

   first=${field[$LEFT, $RIGHT]}
   all_same=1
   for ((s=0; s < $SIZE; s++)); do
      i=$(($TOP + $s))
      j=$(($RIGHT - $s))
      current=${field[$i, $j]}
      if [[ $current != $first ]]; then
         all_same=0
         break
      fi
   done
   if [[ $all_same != 0 && $first ]]; then
      clear
      echo "Winner $first"
      exit 0
   fi
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
      o) if [[ $current_turn = o ]] ; then insert o; current_turn=x; fi ;;
      x) if [[ $current_turn = x ]] ; then insert x; current_turn=o; fi ;;
      q) exit 0 ;;
   esac
   check_winner
done
