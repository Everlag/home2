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


{# /home/{{ user }}/load_x_preferences.sh:
  file.managed:
    - contents: |
        
    - user: {{ user }}
    - group: {{ user }}
    - mode: 744
    - makedirs: True #}