#!/bin/bash
# Build video magicom v2 — footage Miyako MCM-528 yang benar (motif bunga)
# Usage: ./build-magicom-v2.sh A|B
set -e
cd ~/workspace/affiliate-demo

VER="$1"
if [ "$VER" = "A" ]; then
  VO="vo_magicom.mp3"
  CTA="Link ada di komentar!"
  OUT="magicom_vA_final.mp4"
elif [ "$VER" = "B" ]; then
  VO="vo_magicom_dm.mp3"
  CTA="Komen MAU, cek DM!"
  OUT="magicom_vB_final.mp4"
else
  echo "Usage: $0 A|B"; exit 1
fi

UNBOX="media-generation-miyako-unbox-v2-0-28b9b73d-00c2-408c-871a-cecc96cc5ff9.mp4"
DEMO="media-generation-miyako-demo-v2-0-2c65bf43-3ba9-40c8-ada0-8cafb2ddfa3d.mp4"
INTRO="intro_miminngiler.mp4"
WM="miminngiler_watermark.png"
FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

DT="drawtext=fontfile=${FONT}:fontsize=64:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=h*0.70"

ffmpeg -y -loglevel error \
  -i "$UNBOX" -i "$DEMO" -i "$VO" -i "$WM" -i "$INTRO" \
  -filter_complex "\
[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,fps=30[v0]; \
[1:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,fps=30[v1]; \
[v0][v1]concat=n=2:v=1:a=0,trim=0:20,setpts=PTS-STARTPTS, \
${DT}:text='Nasi gampang basi?':enable='between(t,0.5,3.5)', \
${DT}:text='Unboxing dulu~':enable='between(t,3.5,7)', \
${DT}:text='Nasi pulen & anget terus':enable='between(t,7,11)', \
${DT}:text='Hemat listrik, anti lengket':enable='between(t,11,15)', \
${DT}:text='${CTA}':enable='between(t,15,19.8)' \
[vtxt]; \
[3:v]scale=180:-1[wm]; \
[vtxt][wm]overlay=W-w-24:24:format=auto[vmain]; \
[4:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1[vintro]; \
[vintro][vmain]concat=n=2:v=1:a=0[vfinal]; \
[2:a]atrim=0:20,asetpts=PTS-STARTPTS,adelay=3000|3000[vo]; \
[4:a][vo]amix=inputs=2:duration=longest[aout]" \
  -map "[vfinal]" -map "[aout]" -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 128k \
  -movflags +faststart -shortest "$OUT"

echo "OK: $OUT ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")s)"
