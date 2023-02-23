# Last modified: 02/22/23 02:48PM
# Source and readme: https://github.com/spaghetti-guy/merge-audio-and-subs
#
# You can pass the variables directly to the script or you can run it interactively. 
# When calling the script in this way, be sure to surround the paths with quotes if there's spaces
# E.g. .\merge-audio-and-subs.ps1 -ffmpegPath "C:\path\to\ffmpeg.exe" -contentDirectory "C:\path to\your content\" -imagePath "C:\path\to your\image.png"
# If you put ffmpeg in the same directory as this script, it will assume you want to use that one.

param($ffmpegPath, $contentDirectory, $imagePath)

# Read input if required and try to correct paths
if($ffmpegPath -eq $null) {
    if(Test-Path -Path ffmpeg.exe) {
        $ffmpegPath = Get-ChildItem -Path .\ -Filter "ffmpeg.exe"
    } else {
        Write-Host "`nEnter the path to ffmpeg.exe (do not use quotes):"
        $ffmpegPath = Read-Host
    }
}
try {$ffmpegPath = Get-ChildItem -Path $ffmpegPath -Filter "ffmpeg.exe" -ErrorAction Stop}
catch {
    Write-Host "Error: Path to ffmpeg is invalid" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Return
}

if($contentDirectory -eq $null) { 
    Write-Host "`nEnter the path to the directory containing your audio files (do not use quotes):"
    $contentDirectory = Read-Host
}
try {
    if(!(Test-Path -Path $contentDirectory -PathType Container)) {
        throw
    }
}
catch {
    Write-Host "Error: Path to your content is invalid" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Return
}

if($imagePath -eq $null) {
    Write-Host "`nEnter the path to the image you want to use for the video background (do not use quotes):"
    $imagePath = Read-Host
}
try {
    if(!(Test-Path -Path $imagePath -Include "*.jpg","*.jpeg","*.gif","*.png","*.bmp","*.tif","*.tiff")) {
        throw
    }
}
catch {
    Write-Host "Error: Path to your image is inavlid" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Return
}


# Determine format of subtitles
if(Test-Path -Path $contentDirectory\* -Include "*.vtt") {
    $subFileFormat = ".vtt"
} elseif(Test-Path -Path $contentDirectory\* -Include "*.srt") {
    $subFileFormat = ".srt"
} elseif(Test-Path -Path $contentDirectory\* -Include "*.ass") {
    $subFileFormat = ".ass"
} elseif(Test-Path -Path $contentDirectory\* -Include "*.ssa") {
    $subFileFormat = ".ssa"
} elseif(Test-Path -Path $contentDirectory\* -Include "*.sbv") {
    $subFileFormat = ".sbv"
}


# Silently create an output folder for the videos
[Void](mkdir $contentDirectory\merged)


# Start processing each audio file
Get-ChildItem -Path $contentDirectory\* -Include "*.wav","*.mp3"."*.flac","*.m4a","*.ogg","*.oga","*.wma" | ForEach-Object {
    $outputName = $_.Name + ".mkv"
    Write-Host "Creating $contentDirectory\merged\$outputName..."
    & $ffmpegPath -loglevel quiet -loop 1 -framerate 1 -i $imagePath -i $_.FullName -i $_$subFileFormat -shortest -fflags +shortest -max_interleave_delta 200M -acodec copy -scodec copy -disposition:s:0 default $contentDirectory\merged\$outputName
}


Write-Host "`nDone!`n" -ForegroundColor Green