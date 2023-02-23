# merge-audio-and-subs
This is a PowerShell script that takes an image file, an audio file, and a subtitle file as inputs and adds them to an mkv video file using FFmpeg. The audio is not resampled during this process. The result is an mkv video with the orignal audio synced with subtitles that can be played with your video player of choice (tested with MPC-HC and mpv). 

The initial goal of this was to combine .vtt subs with .wav audio, but the script should work for any timestamped subtitles and audio formats supported by FFmpeg

You can use any image for the input, though make sure it's a decent size so the subtitles are legible. There's a 1280x720 solid black image in this repo if you don't care about visuals.

<br>

## Requirements
* You need ffmpeg.exe somewhere accessible. It shouldn't matter which build you use. For reference, I use the codex full release build at: https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z
* The script assumes your subtitles have the exact same name as your audio. E.g. ```audio1.wav``` and ```audio1.wav.vtt```. Adujust accordingly. 

<br>

## 1-line command for single file conversions. 
If you don't want to download a script, you can just run this command in CMD or PowerShell. If you change directories (```cd```) to the location of your inputs, you do not need the full path to them (just their name is fine).
```
.\PathToffmpeg.exe -loop 1 -framerate 1 -i PathToYourImage.png -i PathToYourAudio.wav -i PathToYourSubs.vtt -shortest -acodec copy -scodec copy -disposition:s:0 default SomeOutputName.mkv
```