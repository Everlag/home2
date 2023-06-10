{% set go_url = 'https://go.dev/dl/go1.20.5.linux-amd64.tar.gz' %}
{% set go_hash = 'd7ec48cde0d3d2be2c69203bc3e0a44de8660b9c09a6e85c4732a3f7dc442612' %}
{% set go_tmp = '/tmp/go_tmp.tar.gz' %}

include:
  - common

fetch_package_go:
  cmd.run:
    - name: curl -sSL -o {{ go_tmp }} {{ go_url }}
    - unless: test -f {{ go_tmp }} # don't grab if already grabbed
    - require:
      - pkg: curl

verify_checksum_go:
  cmd.run:
    - name: |
        echo {{ go_hash }} {{ go_tmp }} | sha256sum --check --status
    - require:
      - cmd: fetch_package_go

install_package_go:
  cmd.run:
    - name: |
        rm -rf /usr/local/go
        tar -C /usr/local -xzf {{ go_tmp }}
    - unless: test -d /usr/local/go # don't rerun if already present
    - require:
        - cmd: verify_checksum_go

verify_go:
  cmd.run:
    {# A little dirty PATH stuff for root to see go #}
    - name: PATH=/usr/local/go/bin:$PATH go version
    - require:
      - cmd: install_package_go
