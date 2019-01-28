#!/bin/sh

mkdir -p tn

echo "" > images.md

for img in ss/*.png; do
  tn=${img/ss/tn}
  convert -resize 192x108 ${img} ${tn}
  echo "[![](${tn})](${img})" >> images.md
done
