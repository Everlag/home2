{% set adhoc_server_loc = "/etc/adhoc-server" %}
{% set bin_name = "adhoc-server" %}

{% from "maps/nebula.jinja" import nebula_hosts, nebula_certpack_password with context %}

{% set nebula_host = salt['grains.get']('nebula_hostname') %}
{% set nebula_info = nebula_hosts | selectattr('name', 'equalto', nebula_host) | first %}

{% from "maps/ports.jinja" import ports with context %}

{{adhoc_server_loc}}/server.go:
  file.managed:
    - source: salt://nebula/adhoc-server/server.go
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      nebula_ip: {{ nebula_info['ip'].split('/')[0] }}
      listen_port: {{ ports['adhoc-server'] }}

{{adhoc_server_loc}}/server-bin:
    cmd.run:
      - name: |
          cd {{adhoc_server_loc}}
          /usr/local/go/bin/go build -o {{ bin_name }} server.go
      - onchanges:
          - file: {{adhoc_server_loc}}/server.go
