include:
  - common
  - nebula/nebula_bin

{% set nebula_cfg = "/etc/nebula-main/config.yml" %}

{{ nebula_cfg }}:
  file.managed:
{% if 'nebula-lighthouse' in salt['grains.get']('role') %}
    - source: salt://nebula/config.lighthouse.yml
{% else %}
    - source: salt://nebula/config.node.yml
{% endif %}
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 640

validate_nebula_cfg:
  cmd.run:
  {# TODO: #}
    - name: nebula -config {{ nebula_cfg }} -test
    {# - onchanges:
      - file: {{ nebula_cfg }} #}

{# TODO: get it working #}
{# /etc/systemd/system/nebula.service:
  file.managed:
    - source: salt://nebula/nebula.service
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    # VERY important, this is the last thing we do as this can cause us to
    {# lose networking to nebula nodes temporarily #}
    - order: last 

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
      - file: /etc/systemd/system/nebula.service #}