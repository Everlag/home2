{% set loc = "/etc/syncthing" %}
{% set sync_loc = loc + "/synced" %}

{% from "maps/nebula.jinja" import nebula_hosts with context %}
{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{{ loc }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 666

{# Root of synced data #}
{{ sync_loc }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 666

{{ loc }}/docker-compose.yml:
  file.managed:
    - source: salt://tools/syncthing/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      nebula_ip: {{ nebula_info['ip'].split('/')[0] }}
    
{# Automatically used variables for rendering docker-compose.yml #}
{{ loc }}/.env:
  file.managed:
    - source: salt://tools/syncthing/env
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      sync_loc: {{ sync_loc }}