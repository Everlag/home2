{% set x11docker_url = 'https://github.com/mviereck/x11docker/archive/refs/tags/v7.6.0.zip' %}
{% set x11docker_hash = '713985d522b446c3e71956b0d4e2355d0a28788388b4ab65762ed4e97780547a' %}

{% set x11docker_tmp = '/tmp/x11docker_tmp.zip' %}
{% set x11docker_dir = '/tmp/x11docker_tmp' %}

include:
  - common

{{ x11docker_dir }}:
  cmd.run:
    - name: |
        curl -sSL -o {{ x11docker_tmp }} {{ x11docker_url }}
        7z e -y {{ x11docker_tmp }} -o{{ x11docker_dir }}
    - unless: test -f {{ x11docker_tmp }} # don't grab if already grabbed
    - require:
      - pkg: p7zip-full

verify_checksum_x11docker:
  cmd.run:
    - name: |
        echo {{ x11docker_hash }} {{ x11docker_tmp }} | sha256sum --check --status
    - require:
      - cmd: {{ x11docker_dir }}

x11docker-install:
    cmd.run:
    - name: {{ x11docker_dir }}/x11docker --install
    {# - unless: test -f {{ x11docker_tmp }} # don't grab if already grabbed #}
    - require:
      - cmd: verify_checksum_x11docker
      - cmd: {{ x11docker_dir }}
