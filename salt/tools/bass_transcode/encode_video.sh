IFS=$'\n'
mkdir -p video_output && for i in $(cat list); do echo processing ${i} && ffmpeg -i "${i}" -hide_banner -af silencedetect=n=-40dB:d=2 -f null - 2>&1 | python3 silence_detect_transformer.py > temp_command.sh && chmod +x temp_command.sh && ./temp_command.sh ; done
