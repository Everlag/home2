#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'usage: ./download.sh $URL $URL $URL ...'
    exit 0
fi

IMAGE=ytdlp-bass-transcoder
docker build -t ${IMAGE} -f Dockerfile.ytdlp .
docker run --rm -v `pwd`:/app ${IMAGE} yt-dlp $@