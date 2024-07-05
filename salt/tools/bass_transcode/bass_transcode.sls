{% set loc = "/etc/bass_transcode" %}

{{ loc }}/README:
  file.managed:
    - source: salt://tools/bass_transcode/README
    - user: root
    - group: root
    - mode: 655
    - makedirs: True

{# list files in directory for processing #}
{{ loc }}/list.sh:
  file.managed:
    - source: salt://tools/bass_transcode/list.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{# audio only outputs #}
{{ loc }}/encode_audio.sh:
  file.managed:
    - source: salt://tools/bass_transcode/encode_audio.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{# a/v outputs #}
{{ loc }}/encode_video.sh:
  file.managed:
    - source: salt://tools/bass_transcode/encode_video.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{# silence detecting script to support encode_video #}
{{ loc }}/silence_detect_transformer.py:
  file.managed:
    - source: salt://tools/bass_transcode/silence_detect_transformer.py
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{# Send files to arbitrary hardcoded directory shared by compose torrents #}
{{ loc }}/sync.sh:
  file.managed:
    - source: salt://tools/bass_transcode/sync.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{{ loc }}/Dockerfile.ytdlp:
  file.managed:
    - source: salt://tools/bass_transcode/Dockerfile.ytdlp
    - user: root
    - group: root
    - mode: 655
    - makedirs: True

{{ loc }}/download.sh:
  file.managed:
    - source: salt://tools/bass_transcode/download.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{{ loc }}/backup.sh:
  file.managed:
    - source: salt://tools/bass_transcode/backup.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True