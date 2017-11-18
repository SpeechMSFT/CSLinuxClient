#!/bin/sh
SCRIPT_DIR=/mnt/hgfs/Lab/QnA/Batch/Amazon/script/*
OUTPUT_DIR=/mnt/hgfs/Lab/QnA/Batch/Amazon/

AMAZON_SHELL_PATH=/home/ruyan/Documents/AmazonAVS/alexaqa.py

AMAZON_LOCK_FILE_PATH=/home/ruyan/Documents/amazon_lock

while true
do
  if [ "$(ls -A $SCRIPT_DIR)" ]
  then
    for script_file in $SCRIPT_DIR
    do
      # Wait for if there are any executing amazon tasks.
      while [ -f "$AMAZON_LOCK_FILE_PATH" ]; do
        echo 'Amazon task lock exist.'
        sleep 2
      done

      # Create lock file.
      touch $AMAZON_LOCK_FILE_PATH

      guid=${script_file##*/}
      tts_root=$OUTPUT_DIR$guid'/tts/*'
      input_root=$OUTPUT_DIR$guid'/input/'

      mkdir $input_root

      if [ "$(ls -A $tts_root)" ]
      then
        for audio_file in $tts_root
        do
          audio_filename=${audio_file##*/}
          audio_filename_short=${audio_filename%.*}

          format_opath=$input_root$audio_filename

          sox $audio_file -c 1 -r 16000 -b 16 $format_opath
          avs_ifile=$format_opath
          avs_ofile=$OUTPUT_DIR$guid'/'$audio_filename_short'.mp3'

          python3 $AMAZON_SHELL_PATH $avs_ifile $avs_ofile

          rm $audio_file
          rm $avs_ifile
        done
      fi

      rm $script_file
      rm -rf $input_root
      rm -rf $OUTPUT_DIR$guid'/tts/'

      # Remove lock file.
      rm $AMAZON_LOCK_FILE_PATH
    done
  fi
done
