target_root=/etc/torrent-compose/downloads
echo "copying audio"
mkdir -p ${target_root}/bass_audio/
time cp audio_output/* ${target_root}/bass_audio/

echo "copying video"
mkdir -p ${target_root}/bass_video
time cp video_output/* ${target_root}/bass_video/
