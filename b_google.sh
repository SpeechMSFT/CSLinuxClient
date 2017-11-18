#!/bin/sh
SCRIPT_DIR=/mnt/hgfs/Lab/QnA/Batch/Google/script/*
OUTPUT_DIR=/mnt/hgfs/Lab/QnA/Batch/Google/

GOOGLE_SHELL_PATH=/home/ruyan/Documents/GoogleAssistantSDK/pushtotalk.py

GOOGLE_LOCK_FILE_PATH=/home/ruyan/Documents/google_lock

while true
do
  if [ "$(ls -A $SCRIPT_DIR)" ]
  then
    for script_file in $SCRIPT_DIR
    do
      # Wait for if there are any executing google tasks.
      while [ -f "$GOOGLE_LOCK_FILE_PATH" ]; do
        echo 'Google task lock exist.'
        sleep 2
      done

      # Create lock file.
      touch $GOOGLE_LOCK_FILE_PATH

      guid=${script_file##*/}
      tts_root=$OUTPUT_DIR$guid'/tts/*'
      log_path=$OUTPUT_DIR$guid'/log'

      if [ "$(ls -A $tts_root)" ]
      then
        for audio_file in $tts_root
        do
          audio_filename=${audio_file##*/}

          google_ifile=$audio_file
          google_ofile=$OUTPUT_DIR$guid'/'$audio_filename

          python3 $GOOGLE_SHELL_PATH -i $google_ifile -o $google_ofile

          rm $audio_file

          # Sleep 2 seconds after sending next request.
          sleep 2
        done
      fi

      rm $script_file
      rm -rf $OUTPUT_DIR$guid'/tts/'

      # Remove lock file.
      rm $GOOGLE_LOCK_FILE_PATH
    done
  fi
done
