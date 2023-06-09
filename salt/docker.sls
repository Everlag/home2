include:
  - docker

install_curl:
  pkg.installed:
    - names:
      - curl

{% set sysbox_url = 'https://downloads.nestybox.com/sysbox/releases/v0.6.1/sysbox-ce_0.6.1-0.linux_amd64.deb' %}
{% set sysbox_hash = 'd57dc297c60902d4f7316e4f641af00a2a9424e24dde88bb2bb7d3bc419b0f04' %}
{% set sysbox_tmp = '/tmp/sysbox_tmp.deb' %}

fetch_package_sysbox:
  cmd.run:
    - name: curl -sSL -o {{ sysbox_tmp }} {{ sysbox_url }}
    - unless: test -f {{ sysbox_tmp }} # don't grab if already grabbed
    - require:
      - pkg: install_curl

verify_checksum_sysbox:
  cmd.run:
    - name: |
        echo {{ sysbox_hash }} {{ sysbox_tmp }} | sha256sum --check --status
    - require:
      - cmd: fetch_package_sysbox

{# apt fails to find docker for setup... no idea why, so we use dpkg explicitly #}
install_package_sysbox:
  cmd.run:
    - name: dpkg -i {{ sysbox_tmp }}
    - require:
      - cmd: verify_checksum_sysbox