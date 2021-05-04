# Retro TV video effect

An [ffmpeg](https://ffmpeg.or/) script to apply a retro TV effect to video.

The original is made by [oioiiooixiii](https://oioiiooixiii.blogspot.com), I
only made a few changes.

It is tuned especially for video captures from the [VICE] Commodore 64 emulator,
and for uploading to YouTube.

You might want to tweak things for other video's (especially the framerate).

## Prerequisites

- `bash`
- [ffmpeg](https://ffmpeg.or/)

## Usage

    ./retro-tv.sh <input video file>

An intermediary `tmp.mp4` file is created. It's safe to delete this.

## Capturing video from Vice

Use the following settings for best results:

- Video driver: FFMPEG
- Format: avi
- Video codec: FFV1
- Audio codec: PCM uncompressed
