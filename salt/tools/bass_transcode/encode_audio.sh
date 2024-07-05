# tweaked silence removal...
export IFS=$'\n'
mkdir -p audio_output
for i in $(cat list); do echo "${i}" && nameis=${i%.*} && echo $nameis && ffmpeg -y -i "${i}" -af "areverse,atrim=start=0.2,silenceremove=start_periods=1:start_silence=0.3:start_threshold=0.03,areverse,atrim=start=0.2,silenceremove=start_periods=1:start_silence=0.3:start_threshold=0.03" -f opus audio_output/${nameis}.opus ; done
