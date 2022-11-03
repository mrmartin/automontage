# automontage

A clever commandline tool that converts videos into a single montage using ffmpeg.

Current features:
get a list of video files, and if they are the same resolution, create a montage with randomly chosen s seconds of each

Planned features:
Set the desired length of the output video, multiple shots from each video, and transitions. Cool AI features like detecting nice shots.

## usage

1. create a file `vids.txt` which contains full paths to the videos you want to use
2. make `automontage.sh` executable with `chmod +x automontage.sh`
3. place `automontage.sh` and `vids.txt` in the same folder
4. run `./automontage.sh -s 5 -l vids.txt` to create `montage.mp4` with 5 seconds from each video
