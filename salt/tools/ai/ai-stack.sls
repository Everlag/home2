{% set ai_loc = "/etc/ai-playground" %}
{% set silly_tavern_loc = ai_loc + "/sillytavern" %}
{% set silly_tavern_config_loc = ai_loc + "/sillytavern-config" %}

{% from "maps/nebula.jinja" import nebula_hosts, nebula_certpack_password with context %}

{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{{ silly_tavern_loc }}:
    git.detached:
      - name: https://github.com/SillyTavern/SillyTavern.git
      - rev: 1.9.6
      - target: {{ silly_tavern_loc }}

{{ ai_loc }}/Dockerfile.koboldcpp:
  file.managed:
    - source: salt://tools/ai/Dockerfile.koboldcpp
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja

{{ silly_tavern_config_loc }}/config.conf:
  file.managed:
    - source: salt://tools/ai/sillytavern-config/config.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja

{{ silly_tavern_config_loc }}/settings.json:
  file.managed:
    - source: salt://tools/ai/sillytavern-config/settings.json
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

{{ ai_loc }}/nginx.conf:
    file.managed:
    - source: salt://tools/ai/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja

{{ ai_loc }}/.env:
  file.managed:
    - contents: {{ salt['pillar.get']('ai_model_env') | yaml_encode }}
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

{# Informative #}
{{ ai_loc }}/SELECT_MODEL_WITH_.env:
  file.managed:
    - contents: ''
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

{{ ai_loc }}/docker-compose.yml:
    file.managed:
    - source: salt://tools/ai/docker-compose.yml
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      silly_tavern_config_loc: {{ silly_tavern_config_loc }}
      nebula_ip: {{ nebula_info['ip'].split('/')[0] }}
    - require:
      - git: {{ silly_tavern_loc }}
      - file: {{ ai_loc }}/nginx.conf
      - file: {{ ai_loc }}/Dockerfile.koboldcpp
      - file: {{ silly_tavern_config_loc }}/config.conf
      - file: {{ ai_loc }}/.env

{{ ai_loc }}/boot_stack.sh:
  file.managed:
    - contents: 'docker compose down -v -t0 && docker compose up -d --build'
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - file: {{ ai_loc }}/docker-compose.yml