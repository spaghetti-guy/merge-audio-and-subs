# merge-audio-and-subs
This PowerShell script recursively merges an image file, an audio file, and a subtitle file into a single mkv video using FFmpeg. The audio is not resampled during this process. The result is an mkv video with the orignal audio synced with subtitles that can be played with your video player of choice (tested with MPC-HC and mpv). 

The initial goal of this was to combine .vtt subs with .wav audio, but the script should work for any timestamped subtitles and audio formats supported by FFmpeg (you may need to edit the script if the file extension isn't already included).

<br>

## Requirements
* You need ffmpeg.exe somewhere accessible. It shouldn't matter which build you use. For reference, I use the codex full release build at: https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z
* The script assumes your subtitles have the exact same name as your audio. E.g. `audio1.wav` and `audio1.wav.vtt`. Adujust accordingly.
* You can use any image for the input, though make sure it's a decent resolution so the subtitles are legible. An image with a smaller file size will result in significantly faster encoding. There's a 1280x720 solid black image in this repo if you don't care about visuals and just want to encode as fast as possible.

<br>

## Instructions
1. Download `merge-audio-and-subs.ps1` and put it into a folder somewhere that is easy to find (For example `C:\mergescript`). If you put ffmpeg.exe into the same folder, it'll save you some typing.
2. Open PowerShell (do not run it as an administrator)
3. Change directories to the folder you created for the script (e.g. "`cd C:\mergescript`").
4. Run the script by typing "`.\merge-audio-and-subs.ps1`"
5. Follow the prompts

Note: you can also pass all variables into the script directly rather than running it interactively. For example `.\merge-audio-and-subs.ps1 -ffmpegPath "C:\path\to\ffmpeg.exe" -contentDirectory "C:\path to\your content\" -imagePath "C:\path\to your\image.png"`

<br>

## 1-line FFmpeg command for single file conversions. 
If you don't want to download this script, you can just run this command in CMD or PowerShell. If you set your working directory to the directory with your inputs, you do not need the full path to them (just their name is fine).
```
.\PathToffmpeg.exe -loglevel quiet -loop 1 -framerate 1 -i PathToYourImage.png -i PathToYourAudio.wav -i PathToYourSubs.vtt -shortest -acodec copy -scodec copy -disposition:s:0 default SomeOutputName.mkv
```

<br>

# Troubleshooting
If you receive an error saying something to the effect of "[the script] cannot be loaded because running scripts is disabled on this system", do the following
1. Run PowerShell as administrator (this is just temporary, do not run the merge script as an admin)
2. Type "`Set-ExecutionPolicy Bypass`"
3. Type "`y`" to confirm
4. Close PowerShell and open it again without running it as admin. 

To speed up encoding, use an image with a smaller file size. For example the "solidblack.png" in this repo.