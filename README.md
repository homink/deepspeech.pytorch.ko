# deepspeech.pytorch.ko

A few changes has been made to train Korean. Please review [deepspeech.pytorch](https://github.com/SeanNaren/deepspeech.pytorch/blob/master/README.md) in advance.

## Koren ASR corpus

### Korean read speech corpus (about 120 hours, 17GB) from National Institude of Korean Language

http://www.korean.go.kr/front/board/boardStandardView.do?board_id=4&mn_id=17&b_seq=464

https://ithub.korean.go.kr/user/corpus/referenceManager.do

## Data preparation
```
python nikl.py
```

## Training
```
python train.py --train-manifest data/nikl_train_manifest.csv --val-manifest data/nikl_val_manifest.csv
```
## Prediction
```
python transcribe.py --model-path models/deepspeech_1.pth.tar \
                     --audio-path /DATA/speech-data/NIKL_2007/fv01/fv01_t01_s01.wav > trans.log
echo -e """$(cat trans.log | cut -d':' -f3 | cut -d'"' -f2)"""
```
