{% from "maps/nebula.jinja" import nebula_hosts with context %}

{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{% set nebula_private = "/etc/nebula-main" %}
{% set nebula_cfg = nebula_private + "/config.yml" %}
{% set nebula_cert_pack = "/etc/nebula-certpack.7z" %}

{% set nebula_service_account = "nebula-service" %}
{% set nebula_service_group = "nebula-users" %}

{# TODO: gracefully fail if invalid hostname... #}
{# TODO: don't hang randomly if nebula-main stuff is incorrect state... #}
{# verify_nebula_hostname:
  cmd.run: #}
  
{# We want to run service as a specific user/group #}
{{ nebula_service_group }}_group:
  group.present:
    - name: {{ nebula_service_group }}
    - system: True

{{ nebula_service_account }}:
  user.present:
    - usergroup: True
    - shell: /bin/bash
    - groups:
      - {{ nebula_service_group }}
    - require:
      - group: {{ nebula_service_group }}_group

{# We fixup permissions for included files below #}
{{ nebula_private }}_exist:
  file.directory:
    - name: {{ nebula_private }}
    - user: root
    - group: {{ nebula_service_group }}
    - mode: 770
    - makedirs: True
    - require:
      - group: {{ nebula_service_group }}_group

nebula_cert_pack_exists:
  file.exists:
    - name: {{ nebula_cert_pack }}
  {# Ensure permissions are clean #}
  cmd.run:
    - name: chmod 600 {{ nebula_cert_pack }}
    - stateful: True

nebula_cert_pack_extract:
  cmd.run:
    - name: |
        cd {{ nebula_private }}
        7z x {{ nebula_cert_pack }}
    - unless: test -f {{ nebula_private }}/{{ nebula_host }}.crt && test -f  {{ nebula_private }}/{{ nebula_host }}.key
    - require:
      - cmd: nebula_cert_pack_exists
      - file: {{ nebula_private }}_exist

nebula_cert_validate:
  cmd.run:
    - name: |
        nebula-cert verify -ca {{ nebula_private }}/ca.crt -crt {{ nebula_private }}/{{ nebula_host }}.crt
    - stateful: True
    - require:
        - cmd: nebula_cert_pack_extract

{{ nebula_private }}_permissions:
  file.directory:
    - name: {{ nebula_private }}
    - user: root
    - group: {{ nebula_service_group }}
    - dir_mode: 770
    - file_mode: 660
    - recurse:
      - user
      - group
      - mode
    - require:
      - cmd: nebula_cert_validate

{{ nebula_cfg }}:
  file.managed:
{% if nebula_info['lighthouse'] %}
    - source: salt://nebula/config.lighthouse.yml
{% else %}
    - source: salt://nebula/config.node.yml
{% endif %}
    - makedirs: True
    - user: root
    - group: {{ nebula_service_group }}
    - mode: 660
    - template: jinja
    - context:
      nebula_private: {{ nebula_private }}
    - require:
      - file: {{ nebula_private }}_permissions

validate_nebula_cfg:
  {# If if any non-info logs, we fail #}
  cmd.run:
    {# Note: the >&2 is critical as stateful will only report stdout!! #}
    - name: |
        ERR=$(nebula -config {{ nebula_cfg }} -test | grep error)
        if [ "$?" -eq 0 ]; then 
          >&2 echo ${ERR}
          exit 1
        fi
    - stateful: True
    - require:
       - file: {{ nebula_cfg }}

{# TODO: get it working #}
/etc/systemd/system/nebula.service:
  file.managed:
    - source: salt://nebula/nebula.service
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - context:
      nebula_service_account: {{ nebula_service_account }}
      nebula_private: {{ nebula_private }}
      nebula_host: {{ nebula_host }}
    # VERY important, this is the last thing we do as this can cause us to
    {# lose networking to nebula nodes temporarily #}
    - order: last
    - require:
      - cmd: validate_nebula_cfg
      - user: {{ nebula_service_account }}

systemd-nebula:
  service.running:
    - name: nebula
    - enable: True
    - reload: False
    - watch:
      - file: /etc/systemd/system/nebula.service
      - file: {{ nebula_cfg }}

systemd-nebula-reload:
  module.run: 
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/nebula.service