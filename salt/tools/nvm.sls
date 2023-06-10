{% set nvm_url = 'https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh' %}
{% set nvm_hash = '2ed5e94ba12434370f0358800deb69f514e8bce90f13beb0e1b241d42c6abafd' %}
{% set nvm_tmp = '/tmp/nvm_tmp.sh' %}

{% set user = "kale" %}

include:
  - common

fetch_package_nvm:
  cmd.run:
    - name: curl -sSL -o {{ nvm_tmp }} {{ nvm_url }}
    - unless: test -f {{ nvm_tmp }} # don't grab if already grabbed
    - require:
      - pkg: curl

verify_checksum_nvm:
  cmd.run:
    - name: |
        echo {{ nvm_hash }} {{ nvm_tmp }} | sha256sum --check --status
    - require:
      - cmd: fetch_package_nvm

{% set nvm_dir = '/home/' + user + '/.nvm' %}

install_package_nvm:
  file.directory:
    - name: {{ nvm_dir }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True
  cmd.run:
    {# Important: NVM__DIR must NOT contain a trailing slash #}
    - name: chmod +x {{ nvm_tmp }} && PROFILE=/home/{{ user }}/.bashrc NVM_DIR={{ nvm_dir }} {{ nvm_tmp }}
    - unless: runuser - {{ user }} -c 'nvm version' # don't rerun if already present
    - require:
        - cmd: verify_checksum_nvm

verify_nvm:
  cmd.run:
    - name: runuser - {{ user }} -c 'nvm version'
    - require:
      - cmd: install_package_nvm

node_16:
  cmd.run:
    - name: runuser - {{ user }} -c 'nvm install 16'
    - require:
      - cmd: verify_nvm