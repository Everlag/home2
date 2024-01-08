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
    qbittorent access: http://${NEBULA_IP}/qbittorrent/
    jellyfin access: http://${NEBULA_IP}/jellyfin/web/index.html
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

{# Annoyingly, separately... #}
{{ loc }}/downloads/incomplete:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 666
    - require:
        - file: {{ loc }}/downloads

{{ loc }}/homepage:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 544
    - require:
        - file: {{ loc }}/downloads

{{ loc }}/homepage/tpl:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 544
    - require:
        - file: {{ loc }}/homepage

{{ loc }}/homepage/tpl/docker.yaml:
  file.managed:
    - user: root
    - group: root
    - mode: 544
    - makedirs: True
    - contents: |
        ---
        # For configuration options and examples, please see:
        # https://gethomepage.dev/en/configs/docker/

        my-docker:
          socket: /var/run/docker.sock
    - require:
        - file: {{ loc }}/homepage/tpl

{{ loc }}/homepage/tpl/settings.yaml:
  file.managed:
    - user: root
    - group: root
    - mode: 544
    - makedirs: True
    - contents: |
        ---
        # For configuration options and examples, please see:
        # https://gethomepage.dev/en/configs/settings

        title: {% raw %}{{HOMEPAGE_VAR_TITLE}}{% endraw %}

        headerStyle: boxed

        layout:
          Media:
            style: row
            columns: 3
          Download:
            style: row
            columns: 2

        quicklaunch:
          searchDescriptions: true
          hideInternetSearch: true
          hideVisitURL: true
    - require:
      - file: {{ loc }}/homepage/tpl

{{ loc }}/homepage/tpl/services.yaml:
  file.managed:
    - user: root
    - group: root
    - mode: 544
    - makedirs: True
    - contents: |
        ---
        # For configuration options and examples, please see:
        # https://gethomepage.dev/en/configs/services
        #
        # overwrite annoying default
    - require:
        - file: {{ loc }}/homepage/tpl

/etc/systemd/system/torrent.service:
  file.managed:
    - source: salt://tools/torrent/torrent.service
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      working_dir: {{ loc }}
    # Do this after everything else is setup
    - order: last

systemd-torrent:
  service.running:
    - name: torrent
    - enable: True
    - reload: False
    - watch:
      - file: /etc/systemd/system/torrent.service