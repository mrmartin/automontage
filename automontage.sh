#!/bin/bash
#automontage

#read arguments
usage="$(basename "$0") [-h] [-s n] -- convert any number of video files into a single montage

where:
    -h  show this help text
    -s  segment length from each video (seconds) - default 10"

seg_length=10
while getopts ':hs:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    s) seg_length=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

#get list of video files into invids.txt
ls -1 ~/Videos/* > vids.txt

#get parameters of all video files
rm -f in_video_resolutions.txt
while read video_file; do 
    echo -n $video_file "has size "
    ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $video_file >>in_video_resolutions.txt
    tail -1 in_video_resolutions.txt
done <vids.txt

if [[ $(sort in_video_resolutions.txt | uniq | wc -l) != "1" ]]
then
  echo "there are input videos of multiple resolutions, exiting"
  exit
fi

sort in_video_resolutions.txt | uniq | wc -l >out_video_resolution.txt

rm in_video_resolutions.txt

#make selection of segments
rm -f in_video_durations.txt
rm -f part_*.mp4
counter=0
cat vids.txt | while read video_file; do 
    echo -n $video_file "has duration "
    ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 $video_file >>in_video_durations.txt
    tail -1 in_video_durations.txt
    #prepare individual segments
    counter=$((counter + 1))
    ffmpeg -y -hide_banner -loglevel error -i $video_file -ss 0 -to $seg_length -c copy part_$counter.mp4 < /dev/null
    echo "part_$counter.mp4 created"
done

rm in_video_durations.txt

#join segments into one file
ls -d -1 "$PWD/"part_*.mp4 | sed "s/^/file '/g" | sed "s/$/'/g" >part_list.txt
    
ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i part_list.txt -c copy montage.mp4

echo "montage.mp4 created"

rm -f part_*.mp4