#!/bin/sh
SCRIPT_DIR=/mnt/hgfs/Lab/TTS/Amazon/script/*
OUTPUT_DIR=/mnt/hgfs/Lab/TTS/Amazon/
WORKING_DIR=/home/ruyan/Documents

COMMAND_WAVE_PATH=/mnt/hgfs/Lab/TTS/Amazon/trigger.wav

ONLINE_FILE_DIR=/home/ruyan/Documents/github/jiabailie.github.io/
ONLINE_FILE_NAME=reader.html
ONLINE_FILE_PATH=$ONLINE_FILE_DIR$ONLINE_FILE_NAME

AMAZON_SHELL_PATH=/home/ruyan/Documents/AmazonAVS/alexaqa.py

AMAZON_LOCK_FILE_PATH=/home/ruyan/Documents/amazon_lock
GITHUB_LOCK_FILE_PATH=/home/ruyan/Documents/github_lock

cd $ONLINE_FILE_DIR

while true
do
  if [ "$(ls -A $SCRIPT_DIR)" ]
  then
    for signal_file in $SCRIPT_DIR
    do
      # Wait for if there are any executing amazon tasks.
      while [ -f "$AMAZON_LOCK_FILE_PATH" ] || [ -f "$GITHUB_LOCK_FILE_PATH" ]; do
        echo 'Amazon task lock exist or Github task lock exist.'
        sleep 2
      done

      # Create lock file.
      touch $AMAZON_LOCK_FILE_PATH
      touch $GITHUB_LOCK_FILE_PATH

      guid=${signal_file##*/}
      script_path=$OUTPUT_DIR$guid'/script.txt'

      if [ -f "$script_path" ]
      then
        cursor=0
        echo ' ' >> $script_path

        while read line; do
          if [ ! -z "$line" -a "$line" != " " ]; then
            git pull
            echo $line > $ONLINE_FILE_PATH
            git add reader.html
            git commit -m 'update reader.html'
            git push

            # Sleep 10 seconds until the git operation completed.
            sleep 10

            cursor=$(($cursor+1))

            avs_ofile=$OUTPUT_DIR$guid'/'$cursor'.mp3'

            python3 $AMAZON_SHELL_PATH $COMMAND_WAVE_PATH $avs_ofile
          fi
        done <$script_path
      fi
      rm $signal_file

      # Remove lock file.
      rm $GITHUB_LOCK_FILE_PATH
      rm $AMAZON_LOCK_FILE_PATH
    done
  fi
done
