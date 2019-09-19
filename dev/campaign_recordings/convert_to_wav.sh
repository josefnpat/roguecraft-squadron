#!/bin/sh
rm *.wav

#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
# set me
FILES=*.flac
for f in $FILES
do
  echo "$f"
  ffmpeg -i "$f" "${f%.*}.wav"
done
# restore $IFS
IFS=$SAVEIFS


