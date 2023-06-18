{% set nebula_tar_url = 'https://github.com/slackhq/nebula/releases/download/v1.7.2/nebula-linux-amd64.tar.gz' %}
{% set nebula_tar_hash = '4600c23344a07c9eda7da4b844730d2e5eb6c36b806eb0e54e4833971f336f70' %}

{% set nebula_tar_tmp = '/tmp/nebula_tar_tmp.tar.gz' %}
{% set nebula_tar_dir = '/tmp/nebula_tar_tmp' %}

{{ nebula_tar_dir }}:
  cmd.run:
    - name: |
        mkdir -p {{ nebula_tar_dir }}
        curl -sSL -o {{ nebula_tar_tmp }} {{ nebula_tar_url }}
        tar -xzvf {{ nebula_tar_tmp }} -C {{ nebula_tar_dir }}
    - unless: test -f {{ nebula_tar_tmp }} || nebula # don't grab if already grabbed

verify_checksum_nebula_tar:
  cmd.run:
    - name: |
        echo {{ nebula_tar_hash }} {{ nebula_tar_tmp }} | sha256sum --check --status
    - stateful: True
    - require:
      - cmd: {{ nebula_tar_dir }}

nebula-install:
    cmd.run:
    - name: |
        cp {{ nebula_tar_dir }}/* /usr/bin
    - unless: nebula -version
    - require:
      - cmd: verify_checksum_nebula_tar
      - cmd: {{ nebula_tar_dir }}

nebula-test:
  cmd.run:
  - name: nebula -version | grep -q Version
  - stateful: True
  - require:
      - cmd: nebula-install
