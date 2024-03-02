#!/bin/bash

SRC_PATH="src"

inotifywait -m -r -q -e create --format "%f" --exclude "\/$SRC_PATH\/types\/" $SRC_PATH | while read FILE
do
  if [[ $FILE == *"components.luau" ]]; then
    lune run scripts/lune/generateComponents.luau  
  fi
done

