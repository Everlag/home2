# tweaked silence removal...
export IFS=$'\n'
mkdir -p audio_output
concurrency=8
counter=0
for i in $(cat list); do
        echo "${i}"
        nameis=${i%.*}
        echo $nameis
        ffmpeg -y -i "${i}" -af "areverse,atrim=start=0.2,silenceremove=start_periods=1:start_silence=0.3:start_threshold=0.03,areverse,atrim=start=0.2,silenceremove=start_periods=1:start_silence=0.3:start_threshold=0.03" -f opus audio_output/${nameis}.opus &
        counter=$((counter+1))
        # Note: paralleism here is not the best, this waits for an entire batch
        # of N to complete before proceeding to the next batch.
        if [ $counter -eq $concurrency ]; then
                wait
                counter=0
        fi
done

wait