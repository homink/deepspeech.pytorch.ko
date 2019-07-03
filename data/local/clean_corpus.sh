#!/usr/bin/env bash

echo "$0 $@"  # Print the command line for logging

#NIKL corpus consists of several zip files. 
#You can organize folders into your corpus directory with the following commands
#unzip '*.zip'
#mv -f "3-3(50female)"/* ./
#mv -f "3-3(50male)"/* ./
#rm -rf "3-3(50female)" "3-3(50male)"
#You can delete corpus with the following comand and unzip again if necessary.
#rm -rf Bad* Non* f* m* *.txt *.hwp script* speak*

corpus=$1
data=$2
stage=0

if [ -f $corpus/cleanedup.txt ];then
  echo "NILK corpus was already cleaned up thus bypassed!"
  exit
fi

mkdir -p $data

if [ $stage -le 0 ]; then
  find $corpus -name "*.wav" | grep -v "Bad\|Non\|small" > $data/wav.lst

  split -l $(echo $(($(wc -l $data/wav.lst | awk '{print $1}') / 9))) \
    $data/wav.lst -d $data/wav. --additional-suffix=.slst
  cn=1;for x in $data/*.slst;do mv $x $data/wav.$cn.slst; cn=$((cn+1));done

  local/run.pl JOB=1:10 $data/sox.JOB.info \
    local/check_wavinfo.sh $data/wav.JOB.slst JOB

  echo -n "NIKL corpus has ";
  echo $(expr $(grep Duration $data/sox.*.info | awk '{print $5}' | paste -sd+ | bc) / 57600000)" hours"

  grep "Input\|Sample Rate" $data/sox.*.info | \
    sed 's/.*: //g' | sed "s/'//g" | tr '\n' ' ' | \
    sed 's/16000/16000\n/g' | sed 's/44100/44100\n/g' | 
    sed 's/48000/48000\n/g' | sed 's/^ //g' | \
    grep -v 16000 > $data/Non16KHz_wav.lst

  if [ $(wc -l $data/Non16KHz_wav.lst | awk '{print $1}') -gt 0 ];then
    mkdir -p $corpus/Non16KHz
    cat $data/Non16KHz_wav.lst | while read line;do
      IFS=" " read wavfile samplerate <<< $line
      if [ "$samplerate" -ne 16000 ];then
        fn=$(basename "$wavfile")
        cp $wavfile $corpus/Non16KHz/
        sox $corpus/Non16KHz/$fn -r 16000 $wavfile
      fi
    done
    echo "$(wc -l $data/Non16KHz_wav.lst) files are not sampled with 16KHz thus forcely resampled to 16KHz."
  fi
fi

if [ $stage -le 1 ]; then

  grep FAIL $data/*.info | sed 's/data.*file `//g' | sed 's/\.wav.*/.wav/g' > $data/BadRiff_wav.lst
  if [ $(wc -l $data/BadRiff_wav.lst | awk '{print $1}') -gt 0 ];then
    mkdir -p $corpus/BadRiff
    cat $data/BadRiff_wav.lst | while read wavfile;do
      mv $wavfile $corpus/BadRiff
    done
    echo "$(wc -l $data/BadRiff_wav.lst | awk '{print $1}') files have bad RIFF header thus relocated to $corpus/BadRiff."
  fi
fi

if [ $stage -le 2 ]; then
  #transcription correction
  transfile=$corpus/script_nmbd_by_sentence.txt
  encoding_type=$(file -b -i $transfile | sed 's/.*charset=//g')

  if [ "$encoding_type" != "utf-8" ];then
    echo "$transfile has $encoding_type encoding, converting to utf-8"
    fname=$(basename "$transfile")
    cp $transfile $transfile.old
    iconv -f $encoding_type -t UTF-8 $transfile.old > $transfile.utf8
    echo "$transfile has $encoding_type encoding, converting to $transfile.utf8"
  fi

  python local/clean_trans.py $transfile.utf8 $transfile
  echo "$transfile.utf is cleaned and saved to $transfile"

  python local/extract_trans.py $transfile > $data/trans.txt
  nl=`cat $data/trans.txt | wc -l`
  [ "$nl" -eq 930 ] || echo "Warning: expected 930 lines in script_nmbd_by_sentence.txt, got $nl"
fi

if [ $stage -le 3 ]; then
  awk '{print $1}' $data/trans.txt > $data/tid.lst
  ./run.pl JOB=1:10 $data/wav.JOB.bad \
    local/search_badname.sh $data/wav.JOB.slst $data/tid.lst JOB

  grep NIKL $data/wav.*.bad | sort | sed 's/data.*://g' > $data/BadName_wav.lst

  if [ $(wc -l $data/BadName_wav.lst | awk '{print $1}') -gt 0 ];then
    echo "Modifying corpus due to bad naming"
    mkdir -p $corpus/BadName

    if [ -f $corpus/mv11/'mv11_t07_s4`.wav' ];then
      mv $corpus/mv11/'mv11_t07_s4`.wav' $corpus/BadName/
    fi

    wavfile=$(grep "(" $data/BadName_wav.lst)
    if [ ! -z $wavfile ];then
      cp $wavfile $corpus/BadName/
      mv $wavfile $(echo $wavfile | cut -d'(' -f1).wav
    fi

    wavfile=$(grep "(" $data/BadName_wav.lst | cut -d'(' -f1)
    for wavfile in `grep "-" $data/BadName_wav.lst`;do
      mv $wavfile $corpus/BadName/
    done

    for wavfile in `grep "_S" $data/BadName_wav.lst`;do
      cp $wavfile $corpus/BadName/
      mv $wavfile ${wavfile/_S/_s}
    done

    for wavfile in `grep "_P" $data/BadName_wav.lst`;do
      cp $wavfile $corpus/BadName/
      mv $wavfile ${wavfile/_P/_s}
    done

    for wavfile in `grep "nfy_s06" $data/BadName_wav.lst`;do
      cp $wavfile $corpus/BadName/
      mv $wavfile ${wavfile/nfy_s06/fx08}
    done
  fi
fi

if [ $stage -le 4 ]; then
  if [ -f $corpus/fv13/"fv13_t06_s37 .wav" ];then
    cp $corpus/fv13/"fv13_t06_s37 .wav" $corpus/BadName/
    mv $corpus/fv13/"fv13_t06_s37 .wav" $corpus/fv13/fv13_t06_s37.wav
  fi

  if [ -f $corpus/fv03/fv03_t04_s562.wav ];then
    cp $corpus/fv03/fv03_t04_s562.wav $corpus/BadName/
    mv $corpus/fv03/fv03_t04_s562.wav $corpus/fv03/fv03_t04_s62.wav
  fi

  if [ -f $corpus/mw15/mw15_t10_s63.wav ];then

    mv $corpus/mw15/mw15_t10_s63.wav $corpus/BadName/
    cp $corpus/mw15/mw15_t08_s28.wav $corpus/BadName/
    mv $corpus/mw15/mw15_t08_s28.wav $corpus/mw15/mw15_t08_s29.wav
    mv $corpus/mw15/mw15_t08_s27.wav $corpus/BadName/
    cp $corpus/mw15/mw15_t08_s26.wav $corpus/BadName/
    mv $corpus/mw15/mw15_t08_s26.wav $corpus/mw15/mw15_t08_s28.wav
    cp $corpus/mw15/mw15_t08_s25.wav $corpus/BadName/
    mv $corpus/mw15/mw15_t08_s25.wav $corpus/mw15/mw15_t08_s27.wav
    cp $corpus/mw15/mw15_t08_s24.wav $corpus/BadName/
    mv $corpus/mw15/mw15_t08_s24.wav $corpus/mw15/mw15_t08_s26.wav
    cp $corpus/mw15/mw15_t08_s23.wav $corpus/BadName/
    mv $corpus/mw15/mw15_t08_s23.wav $corpus/mw15/mw15_t08_s25.wav
    mv $corpus/mw15/mw15_t08_s22.wav $corpus/BadName/

    cp $corpus/fv13/fv13_t10_w43.wav $corpus/BadName/
    mv $corpus/fv13/fv13_t10_w43.wav $corpus/fv13/fv13_t10_s43.wav
    cp $corpus/fv13/fv13_t13_233.wav $corpus/BadName/
    mv $corpus/fv13/fv13_t13_233.wav $corpus/fv13/fv13_t13_s33.wav
    cp $corpus/fv18/fv18_t07_s63.wav $corpus/BadName/
    mv $corpus/fv18/fv18_t07_s63.wav $corpus/fv18/fv18_t07_s62.wav
    cp $corpus/mw11/mw11_t16_s37.wav $corpus/BadName/
    mv $corpus/mw11/mw11_t16_s37.wav $corpus/mw11/mw11_t17_s02.wav
    cp $corpus/fy17/fy17_t15_s18.wav $corpus/BadName/
    mv $corpus/fy17/fy17_t15_s18.wav $corpus/fy17/fy17_t16_s01.wav

    mv $corpus/fx02/fx02_t09_s44.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s43.wav $corpus/BadName/
    cp $corpus/fx02/fx02_t09_s42.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s42.wav $corpus/fx02/fx02_t09_s44.wav
    cp $corpus/fx02/fx02_t09_s41.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s41.wav $corpus/fx02/fx02_t09_s43.wav
    cp $corpus/fx02/fx02_t09_s40.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s40.wav $corpus/fx02/fx02_t09_s42.wav
    cp $corpus/fx02/fx02_t09_s39.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s39.wav $corpus/fx02/fx02_t09_s41.wav
    cp $corpus/fx02/fx02_t09_s38.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s38.wav $corpus/fx02/fx02_t09_s40.wav
    cp $corpus/fx02/fx02_t09_s37.wav $corpus/BadName/
    mv $corpus/fx02/fx02_t09_s37.wav $corpus/fx02/fx02_t09_s39.wav
    mv $corpus/fx02/fx02_t09_s36.wav $corpus/BadName/

    mv $corpus/fx01/fx01_t01_s40.wav $corpus/BadName/
    cp $corpus/fx01/fx01_t01_s39.wav $corpus/BadName/
    mv $corpus/fx01/fx01_t01_s39.wav $corpus/fx01/fx01_t01_s41.wav
    cp $corpus/fx01/fx01_t01_s38.wav $corpus/BadName/
    mv $corpus/fx01/fx01_t01_s38.wav $corpus/fx01/fx01_t01_s40.wav
    mv $corpus/fx01/fx01_t01_s37.wav $corpus/BadName/

  fi
fi

echo "DONE" > $corpus/cleanedup.txt
