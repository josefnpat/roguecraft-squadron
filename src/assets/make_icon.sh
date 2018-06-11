#!/bin/sh

convert "$1" -modulate 300% -thumbnail 32x32 +dither -colors 8\
  -colorspace gray -normalize "$2"
