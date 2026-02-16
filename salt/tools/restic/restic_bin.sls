{% set restic_tar_url = 'https://github.com/restic/restic/releases/download/v0.18.1/restic_0.18.1_linux_amd64.bz2' %}
{% set restic_tar_hash = '680838f19d67151adba227e1570cdd8af12c19cf1735783ed1ba928bc41f363d' %}

{% set restic_tar_tmp = '/tmp/restic_tar_tmp.tar.gz' %}
{% set restic_unzipped = '/tmp/restic_tmp' %}

{{ restic_unzipped }}:
  cmd.run:
    - name: |
        curl -sSL -o {{ restic_tar_tmp }} {{ restic_tar_url }}
        bunzip2 -c {{ restic_tar_tmp }} > {{ restic_unzipped }}
    - unless: test -f {{ restic_tar_tmp }} || restic # don't grab if already grabbed

verify_checksum_restic_tar:
  cmd.run:
    - name: |
        echo {{ restic_tar_hash }} {{ restic_tar_tmp }} | sha256sum --check --status
    - stateful: True
    - require:
      - cmd: {{ restic_unzipped }}

restic-install:
    cmd.run:
    - name: |
        cp {{ restic_unzipped }} /usr/bin/restic
        chmod +x /usr/bin/restic
    - unless: restic version
    - require:
      - cmd: verify_checksum_restic_tar
      - cmd: {{ restic_unzipped }}

restic-test:
  cmd.run:
  - name: restic version | grep -q "compiled with"
  - stateful: True
  - require:
      - cmd: restic-install
