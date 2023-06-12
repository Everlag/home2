{% set mullvad_url = 'https://mullvad.net/en/download/app/deb/latest' %}
{% set mullvad_tmp = '/tmp/mullvad_tmp.deb' %}

{% from "maps/user.jinja" import user with context %}

include:
  - common

fetch_package_mullvad:
  cmd.run:
    - name: curl -sSL -o {{ mullvad_tmp }} {{ mullvad_url }}
    - unless: test -f {{ mullvad_tmp }} # don't grab if already grabbed
    - require:
      - pkg: curl

install_package_mullvad:
  cmd.run:
    - name: apt-get install -y {{ mullvad_tmp }}
    - unless: mullvad version # don't rerun if already present

mullvad_lockdown_mode:
  cmd.run:
    - name: mullvad lockdown-mode set on
    - unless: mullvad lockdown-mode get | grep -q 'will be blocked' # don't rerun if already present

/home/{{ user }}/mullvad_register.sh:
  file.managed:
    - contents: |
        set -x
        # Toggle off temporarily
        sudo mullvad lockdown-mode set off
        sudo mullvad account login
        sudo mullvad lockdown-mode set on
    - user: {{ user }}
    - group: {{ user }}
    - mode: 744
    - makedirs: True

/home/{{ user }}/mullvad_allow_network.sh:
  file.managed:
    - contents: |
        set -x
        sudo mullvad lockdown-mode set off
    - user: {{ user }}
    - group: {{ user }}
    - mode: 744
    - makedirs: True