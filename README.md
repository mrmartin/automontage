# automontage

A clever commandline tool that converts videos into a single montage using ffmpeg. 

Current features:
get a list of video files, and if they are the same resolution, create a montage with the first s seconds of each

Planned features:
You can set the desired length of the output video, as well as transitions, and cut length. Cool AI features like detecting nice shots.

## usage

create a file vids.txt which contains full paths to the videos you want to use
place automontage.sh and vids.txt in the same folder
run ./automontage.sh -s 5 to create montage.mp4 with 5 seconds from each video
