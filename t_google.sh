#!/bin/sh
SCRIPT_DIR=/mnt/hgfs/Lab/TTS/Google/script/*
OUTPUT_DIR=/mnt/hgfs/Lab/TTS/Google/
WORKING_DIR=/home/ruyan/Documents

COMMAND_START_WAVE_PATH=/mnt/hgfs/Lab/TTS/Google/start.wav
COMMAND_TRIGGER_WAVE_PATH=/mnt/hgfs/Lab/TTS/Google/trigger.wav
COMMAND_END_WAVE_PATH=/mnt/hgfs/Lab/TTS/Google/goodbye.wav

ONLINE_FILE_DIR=/home/ruyan/Documents/github/jiabailie.github.io/
ONLINE_FILE_NAME=gaction.html
ONLINE_FILE_PATH=$ONLINE_FILE_DIR$ONLINE_FILE_NAME

GOOGLE_SHELL_PATH=/home/ruyan/Documents/GoogleAssistantSDK/pushtotalk.py

GOOGLE_LOCK_FILE_PATH=/home/ruyan/Documents/google_lock
GITHUB_LOCK_FILE_PATH=/home/ruyan/Documents/github_lock

cd $ONLINE_FILE_DIR

while true
do
  if [ "$(ls -A $SCRIPT_DIR)" ]
  then
    for signal_file in $SCRIPT_DIR
    do
      # Wait for if there are any executing google tasks.
      while [ -f "$GOOGLE_LOCK_FILE_PATH" ] || [ -f "$GITHUB_LOCK_FILE_PATH" ]; do
        echo 'Google task lock exist or Github task lock exist.'
        sleep 2
      done

      # Create lock file.
      touch $GOOGLE_LOCK_FILE_PATH
      touch $GITHUB_LOCK_FILE_PATH

      guid=${signal_file##*/}
      script_path=$OUTPUT_DIR$guid'/script.txt'

      if [ -f "$script_path" ]
      then
        cursor=0
        echo ' ' >> $script_path

        # Start the Google Action.
        # google_ofile=$OUTPUT_DIR$guid'/0.wav'
        # python3 $GOOGLE_SHELL_PATH -i $COMMAND_START_WAVE_PATH -o $google_ofile
        python3 $GOOGLE_SHELL_PATH -i $COMMAND_START_WAVE_PATH

        while read line; do
          if [ ! -z "$line" -a "$line" != " " ]; then
            git pull
            echo $line > $ONLINE_FILE_PATH
            git add gaction.html
            git commit -m 'update gaction.html'
            git push

            # Sleep 10 seconds until the git operation completed.
            sleep 10

            cursor=$(($cursor+1))

            google_ofile=$OUTPUT_DIR$guid'/'$cursor'.wav'

            python3 $GOOGLE_SHELL_PATH -i $COMMAND_TRIGGER_WAVE_PATH -o $google_ofile
          fi
        done <$script_path

        # End the Google Action.
        # google_ofile=$OUTPUT_DIR$guid'/e.wav'
        # python3 $GOOGLE_SHELL_PATH -i $COMMAND_END_WAVE_PATH -o $google_ofile
        python3 $GOOGLE_SHELL_PATH -i $COMMAND_END_WAVE_PATH
      fi
      rm $signal_file

      # Remove lock file.
      rm $GITHUB_LOCK_FILE_PATH
      rm $GOOGLE_LOCK_FILE_PATH
    done
  fi
done
