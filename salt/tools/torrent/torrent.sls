{% set loc = "/etc/torrent-compose" %}
{% set mullvad_private_key = pillar['mullvad']['private_key'] %}
{% set mullvad_addresses = pillar['mullvad']['addresses'] %}

{% from "maps/nebula.jinja" import nebula_hosts, nebula_certpack_password with context %}
{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{{ loc }}/docker-compose.yml:
  file.managed:
    - source: salt://tools/torrent/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      nebula_ip: {{ nebula_info['ip'].split('/')[0] }}

{{ loc }}/.env:
  file.managed:
    - source: salt://tools/torrent/env
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      mullvad_private_key: {{ mullvad_private_key }}
      mullvad_addresses: {{ mullvad_addresses }}

{{ loc }}/qbittorrent/qBittorrent/qBittorrent.conf:
  file.managed:
    - source: salt://tools/torrent/qBittorrent.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True