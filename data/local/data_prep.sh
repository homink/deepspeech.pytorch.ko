#!/usr/bin/bash

corpus=$1
data=$2
stage=0

echo "$0 $@"  # Print the command line for logging

mkdir -p $data

function nums {
  if [ "$1" -lt 10 ];then
    echo "0""$1"
  else
    echo "$1"
  fi
}

if [ $stage -le 0 ]; then

  find $corpus -name "*.wav" | grep -v "Bad\|Non\|small" | sort | uniq > $data/wav.lst
  age=$(cat $data/wav.lst | grep -v "Bad\|Non" | cut -d'/' -f6 | sed 's/[0-9].*//g' | sort | uniq)

  rm -f $data/wav.test.lst
  rm -f $data/wav.train.lst
  for ad in $age;do
    for ((ns=1;ns<=20;ns++));do
      for ((tp=1;tp<=19;tp++));do
        if [ "$ns" -gt 18 ];then
          if [ "$tp" -gt 17 ];then
            if [[ $ad == *"v"* ]] || [[ $ad == *"x"* ]] || [[ $ad == *"w"* ]]; then
              grep $ad$(nums $ns)"_t"$(nums $tp) $data/wav.lst >> $data/wav.test.lst
            fi
          fi

        else
          if [ "$tp" -lt 18 ];then
            grep $ad$(nums $ns)"_t"$(nums $tp) $data/wav.lst >> $data/wav.train.lst
          fi
        fi
      done
    done
  done

  echo "training wav $(wc -l $data/wav.train.lst) will be processed"
  echo "test wav $(wc -l $data/wav.test.lst) will be processed"
fi

if [ $stage -le 1 ]; then
  for x in test train;do
    mkdir -p $data/$x/nikl/wav
    mkdir -p $data/$x/nikl/txt
    cat $data/wav.$x.lst | while read wavfile;do
      cp $wavfile $data/$x/nikl/wav
      uid=$(echo $wavfile | cut -d'/' -f7 | sed 's/.wav//g')
      transid=$(cut -d'_' -f2-3 <<< $uid)
      grep $transid $data/trans.txt | awk '{$1=""}1' | sed 's/^[ \t]*//'g > $data/$x/nikl/txt/$uid.txt
      break
    done
  done
fi
