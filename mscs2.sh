#!/bin/sh
AMAZON_ROOT=/mnt/hgfs/Lab/QnA/QnAGenerator/QnAPortal/batch/amazon/
GOOGLE_ROOT=/mnt/hgfs/Lab/QnA/QnAGenerator/QnAPortal/batch/google/

AMAZON_SHELL_ROOT=/home/ruyan/Documents/AmazonAVS/alexaqa.py
GOOGLE_SHELL_ROOT=/home/ruyan/Documents/GoogleAssistantSDK/pushtotalk.py

ORIGIN_WAVE_ROOT=/mnt/hgfs/Lab/QnA/QnAGenerator/QnAPortal/batch/origin/
ORIGIN_WAVE_ALL=/mnt/hgfs/Lab/QnA/QnAGenerator/QnAPortal/batch/origin/*
FORMATED_WAVE_ROOT=/mnt/hgfs/Lab/QnA/QnAGenerator/QnAPortal/batch/input/

FORMATED_WAVE_ALL=$FORMATED_WAVE_ROOT'*'
MP3_EXTENSION='.mp3'

AmazonGenerator () {
  # Generate waves for Amazon.
  amazon_ipath=$AMAZON_ROOT'm'$process_filename
  amazon_opath=$AMAZON_ROOT$process_filename_short$MP3_EXTENSION

  sox $file_path -r 16k $amazon_ipath

  python3 $AMAZON_SHELL_ROOT $amazon_ipath $amazon_opath

  rm $amazon_ipath
}

GoogleGenerator() {
  # Generate waves for Google.
  google_opath=$GOOGLE_ROOT$process_filename_short$MP3_EXTENSION
  google_ipath=$GOOGLE_ROOT'i'$process_filename

  python3 $GOOGLE_SHELL_ROOT -i $file_path -o $google_ipath
  lame -b 32 -m s $google_ipath $google_opath
}

# 1. Clean environment
echo "Clean environment..."

rm -rf $GOOGLE_ROOT
rm -rf $AMAZON_ROOT

mkdir $GOOGLE_ROOT
mkdir $AMAZON_ROOT

echo "Clean environment successful."

# 2. Format input waves
echo "Format input waves..."

# Clear formated wave directory.
rm -rf $FORMATED_WAVE_ROOT
mkdir $FORMATED_WAVE_ROOT

echo "Clear formated wave directory."

# 3. Generate waves
echo "Generate waves..."

while true
do
  if [ "$(ls -A $ORIGIN_WAVE_ALL)" ]
  then
    for file in $ORIGIN_WAVE_ALL
    do
      process_filename=${file##*/}

      # file name without extension.
      process_filename_short=${process_filename%.*}

      format_ipath=$ORIGIN_WAVE_ROOT$process_filename
      format_opath=$FORMATED_WAVE_ROOT$process_filename

      sox $format_ipath -c 1 -r 24000 -b 16 $format_opath

      file_path=$format_opath

      rm $format_ipath

      AmazonGenerator &
      GoogleGenerator &
      wait

      rm $format_opath
    done
  fi
done
