
pitch_algos=192
speed_algos=72
throat_algos=110
mouth_algos=105

pitch_mati=55
speed_mati=90
throat_mati=140
mouth_mati=135

mkdir -p output
rm output/*.ogg

for dojeer in mati algos; do
  echo "Processing $dojeer ..."
  for filename in $dojeer/*; do
    echo "Processing $filename ..."
    echo $(basename $filename)

    pitch=pitch_$dojeer
    speed=speed_$dojeer
    throat=throat_$dojeer
    mouth=mouth_$dojeer

    ./sam \
      -pitch ${!pitch} \
      -speed ${!speed} \
      -throat ${!throat} \
      -mouth ${!mouth} \
      -wav tmp.wav $(< $filename)
    target=output/$(basename $filename).ogg
    rm $target
    ffmpeg -i tmp.wav -filter:a "volume=0.375" $target
    rm tmp.wav
  done
done



