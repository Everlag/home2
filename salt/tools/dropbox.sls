{% set remote_url = 'https://linux.dropboxstatic.com/packages/debian/dropbox_2024.04.17_amd64.deb' %}
{% set expected_hash = 'dc8d89de693dcc90f8e49b97b5315e6a3863507c3e183c99e451990e758deb91' %}

{% set local_file_loc = '/tmp/dropbox.' + expected_hash + '.deb' %}

{{ local_file_loc }}:
  cmd.run:
    - name: |
        curl -sSL -o {{ local_file_loc }} {{ remote_url }}
    - unless: test -f {{ local_file_loc }} # todo || dropbox

verify_checksum_dropbox_tar:
  cmd.run:
    - name: |
        echo {{ expected_hash }} {{ local_file_loc }} | sha256sum --check --status
    - stateful: True
    - require:
      - cmd: {{ local_file_loc }}

install_package_sysbox:
  cmd.run:
    - name: apt-get install -f {{ local_file_loc }}
    - unless: dpkg -l | grep dropbox # don't rerun if already present
    - require:
      - cmd: verify_checksum_dropbox_tar
