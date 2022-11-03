#!/bin/bash
#automontage

#read arguments
usage="$(basename "$0") [-h] [-s n] [-l f] [-o f] -- convert any number of video files into a single montage

where:
    -h  show this help text
    -s  segment length from each video (seconds) - default 10
    -l  file containing list of videos (one per line, absolute path) - default vids.txt
    -o  output video - default montage.mp4"

seg_length=10
list_of_videos_file=vids.txt
montage_file=montage.mp4
while getopts ':hslo:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    s) seg_length=$OPTARG
       ;;
    l) list_of_videos_file=$OPTARG
       ;;
    o) montage_file=$OPTARG
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

#get parameters of all video files
rm -f in_video_resolutions.txt
while read video_file; do 
    echo -n $video_file "has size "
    ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$video_file" >>in_video_resolutions.txt
    tail -1 in_video_resolutions.txt
done <$list_of_videos_file

if [[ $(sort in_video_resolutions.txt | uniq | wc -l) != "1" ]]
then
  echo "there are input videos of multiple resolutions, exiting"
  exit
fi

#not used
sort in_video_resolutions.txt | uniq | wc -l >out_video_resolution.txt

rm in_video_resolutions.txt out_video_resolution.txt

#make selection of segments
rm -f in_video_durations.txt
rm -f part_*.mp4
counter=0
cat $list_of_videos_file | while read video_file; do 
    echo -n $video_file "has duration "
    ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "$video_file" >>in_video_durations.txt
    tail -1 in_video_durations.txt
    #prepare individual segments
    counter=$((counter + 1))
    duration_in_seconds_round_down=`tail -1 in_video_durations.txt | sed 's/\.[0-9]*//g' | sed 's/,[0-9]*//g'`
    let "max_length = $duration_in_seconds_round_down - $seg_length"
    from=`shuf -i 0-$max_length -n 1`
    let "to = $from + $seg_length"
    echo "selecting segment from ${from}s to ${to}s in video $video_file"
    ffmpeg -y -hide_banner -loglevel error -i "$video_file" -ss $from -to $to -c copy part_$counter.mp4 < /dev/null
    echo "part_$counter.mp4 created"
done

rm in_video_durations.txt

#join segments into one file
ls -d -1 "$PWD/"part_*.mp4 | sed "s/^/file '/g" | sed "s/$/'/g" >part_list.txt
    
ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i part_list.txt -c copy $montage_file

echo "${montage_file} created"

rm -f part_*.mp4 part_list.txt