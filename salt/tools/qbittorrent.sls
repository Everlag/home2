{% from "maps/user.jinja" import user with context %}

qbittorrent:
  pkg:
    - installed

qbittorrent_default_downloads_/home/{{ user }}/Downloads:
  file.directory:
    - name: /home/{{ user }}/Downloads
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

/home/{{ user }}/.config/qBittorrent/qBittorrent.conf:
  file.managed:
    - source: salt://tools/qBittorrent.conf
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True
    - require:
      - pkg: qbittorrent
    - template: jinja
    - context:
      user: {{ user }}