# Last modified: 08/28/23 11:39PM
# Source and readme: https://github.com/spaghetti-guy/merge-audio-and-subs
#
# You can pass the variables directly to the script or you can run it interactively. 
# When calling the script in this way, be sure to surround the paths with quotes if there's spaces
# E.g. .\merge-audio-and-subs.ps1 -ffmpegPath "C:\path\to\ffmpeg.exe" -contentDirectory "C:\path to\your content\" -imagePath "C:\path\to your\image.png"
# If you put ffmpeg in the same directory as this script, it will assume you want to use that one.



param($ffmpegPath, $contentDirectory, $imagePath, $fps)

Add-Type -AssemblyName System.Windows.Forms

# Read input if required and try to correct paths
if($ffmpegPath -eq $null) {
    if(Test-Path -Path ffmpeg.exe) {
        $ffmpegPath = Get-ChildItem -Path .\ -Filter "ffmpeg.exe"
    } else {
        Write-Host "ffmpeg.exe not found in the current directory and not passed in via parameter, select ffmpeg.exe" -ForegroundColor Yellow

        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = $pwd; Title = "Select ffmpeg.exe"; Filter = "ffmpeg|ffmpeg.exe"}
        $null = $fileBrowser.ShowDialog()
        $ffmpegPath = $fileBrowser.FileName
    }
}
try {
    $ffmpegPath = Get-ChildItem -Path $ffmpegPath -Filter "ffmpeg.exe" -ErrorAction Stop
    if(!($ffmpegPath -match "\\ffmpeg.exe")){
        throw
    }
}
catch {
    Write-Host "Error: Path to ffmpeg is invalid" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Return
}

Write-Host "Using ffmpeg.exe at `"$ffmpegpath`"" -ForegroundColor Green

if($contentDirectory -eq $null) {
    Write-Host "Content directory not passed in via parameter, select the folder containing your audio and subs" -ForegroundColor Yellow

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ InitialDirectory = $pwd; Description = "Select the folder containing your audio and subs"; UseDescriptionForTitle = $true}
    $null = $folderBrowser.ShowDialog()
    $contentDirectory = $folderBrowser.SelectedPath
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

Write-Host "Using the content directory at `"$contentDirectory`"" -ForegroundColor Green

if($imagePath -eq $null) {
    Write-Host "Image path not passed in via parameter, select the image you'd like to use for the video" -ForegroundColor Yellow

    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = $pwd; Title = "Select your image"; Filter = "Image (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg"}
    $null = $fileBrowser.ShowDialog()
    $imagePath = $fileBrowser.FileName
}
try {
    if(!(Test-Path -Path $imagePath -Include "*.jpg","*.jpeg","*.gif","*.png")) {
        throw
    }
}
catch {
    Write-Host "Error: Path to your image is inavlid" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Return
}

Write-Host "Using the image at `"$imagePath`"" -ForegroundColor Green

if($fps -eq $null) {
    Write-Host "`nEnter desired frames per second. A smaller number means faster encodes, but subtitles may be delayed in their presentation."
    Write-Host "1 is absolute fastest encode. 6 is probably tolerable for most people. 12 for those sensitive to timing but expect longer encode times."
    $fps = Read-Host "FPS"
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
    & $ffmpegPath -loglevel quiet -loop 1 -framerate $fps -i $imagePath -i $_.FullName -i $_$subFileFormat -shortest -fflags +shortest -max_interleave_delta 200M -vcodec libx264 -preset ultrafast -crf 0 -acodec copy -scodec copy -disposition:s:0 default $contentDirectory\merged\$outputName
}


Write-Host "`nDone!`n" -ForegroundColor Green