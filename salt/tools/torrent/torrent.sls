{% set loc = "/etc/torrent-compose" %}
{% set mullvad_private_key = pillar['mullvad']['private_key'] %}
{% set mullvad_addresses = pillar['mullvad']['addresses'] %}

{% from "maps/nebula.jinja" import nebula_hosts, nebula_certpack_password with context %}
{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{#
    This is based off a modified version of docker-compose-nas
    https://github.com/AdrienPoupa/docker-compose-nas

    Stripped down and with different opinions.
    Typical access: http://${NEBULA_IP}/qbittorrent/
#}

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

{{ loc }}/downloads:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 666