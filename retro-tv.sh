#!/bin/bash

# A collection of FFmpeg filterchains which can be used to create a stylised
# 'CRT screen' effect on given input.
#
# The filter-chains have been split apart to increase modularity, at the cost of
# sacrificing simplicity and increasing redundant code. Filter-chains can be
# added or removed in various orders, but special attention must be paid to
# selecting the correct termination syntax for each stage.
#
# Includes basic demonstration FFmpeg command which takes "$1" input file.
#
# Version: 2019.04.06_02.49.13
# Source https://oioiiooixiii.blogspot.com

# https://video.stackexchange.com/questions/12105/add-an-image-overlay-in-front-of-video-using-ffmpeg
# https://superuser.com/questions/460332/how-do-set-output-framerate-same-as-source-in-ffmpeg

### FILTERCHAINS ###############################################################

set -e

# Reduce input to 50% PAL resolution
shrink288="scale=-2:270"

# Crop to 4:3 aspect ration at 50% PAL resolution
crop43="crop=360:270"

# Create RGB chromatic aberration
rgbFX="split=3[red][green][blue];
      [red] lutrgb=g=0:b=0,
            scale=368x270,
            crop=360:270 [red];
      [green] lutrgb=r=0:b=0,
              scale=364x270,
              crop=360:270 [green];
      [blue] lutrgb=r=0:g=0,
             scale=360x270,
             crop=360:270 [blue];
      [red][blue] blend=all_mode='addition' [rb];
      [rb][green] blend=all_mode='addition',
                  format=gbrp"

# Add noise to each frame of input
noiseFX="noise=c0s=7:allf=t"

# Add interlaced fields effect to input
interlaceFX="split[a][b];
             [a] curves=vintage [a];
             [a][b] blend=all_expr='if(eq(0,mod(Y,2)),A,B)':shortest=1"

# Re-scale input to full PAL resolution
scale2PAL="scale=768:576"

# Scale and pad to 1080p, aligned for overlay picture
scale1080="scale=1054:804,pad=1920:1080:288:100"

# Add magnetic damage effect to input [crt screen]
screenGauss="[base];
             nullsrc=size=768x576,
                drawtext=
                   text='@':
                   x=600:
                   y=30:
                   fontsize=170:
                   fontcolor=red@1.0,
             boxblur=80 [gauss];
             [gauss][base] blend=all_mode=screen:shortest=1"

# Add reflections to input [crt screen]
reflections="[base];
             nullsrc=size=768x576,
             format=gbrp,
             drawtext=
               text='€':
               x=50:
               y=50:
               fontsize=150:
               fontcolor=white,
             drawtext=
               text='J':
               x=600:
               y=460:
               fontsize=120:
               fontcolor=white,
             boxblur=25 [lights];
             [lights][base] blend=all_mode=screen:shortest=1"

# Add more detailed highlight to input [crt screen]
highlight="[base];
             nullsrc=size=768x576,
             format=gbrp,
             drawtext=
               text='¡':
               x=80:
               y=60:
               fontsize=90:
               fontcolor=white,
             boxblur=7 [lights];
             [lights][base] blend=all_mode=screen:shortest=1"

# Curve input to mimic curve of crt screen
curveImage="vignette,
            format=gbrp,
            lenscorrection=k1=0.05:k2=0.05"

# Add bloom effect to input [crt screen]
bloomEffect="split [a][b];
             [b] boxblur=26,
                 format=gbrp [b];
             [b][a] blend=all_mode=softlight:shortest=1"

### FFMPEG COMMAND #############################################################
         #${yuvFX},
         #${interlaceFX},
         #${bloomEffect},

#ffmpeg \
   #-framerate 50 \
   #-i "$1" \
   #-vf "
         #${shrink288},
         #${crop43},
         #${rgbFX},
         #${noiseFX},
         #${interlaceFX},
         #${scale2PAL}
         #${screenGauss}
         #${reflections}
         #${highlight},
         #${curveImage},
         #${bloomEffect},
         #${scale1080}
      #" \
   #"tmp.mp4"

ffmpeg \
   -i "$1" \
   -vsync vfr \
   -r 50.12 \
   -q:a 1 \
   -c:a aac \
   -b:a 384k \
   -ac 2 \
   -vf "
         ${shrink288},
         ${crop43},
         ${rgbFX},
         ${noiseFX},
         ${interlaceFX},
         ${scale2PAL}
         ${screenGauss}
         ${reflections}
         ${highlight},
         ${curveImage},
         ${bloomEffect},
         ${scale1080},
         framerate,fps=50.12
      " \
   "tmp.mp4"

ffmpeg -i tmp.mp4 -i tv.png \
  -filter_complex "[0:v][1:v] overlay=0:0" \
  -c:a copy \
  "$1-crt.mp4"
#rm "tmp.mp4"
