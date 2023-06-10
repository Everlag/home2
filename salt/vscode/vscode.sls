{% set vscode_url = 'https://az764295.vo.msecnd.net/stable/b380da4ef1ee00e224a15c1d4d9793e27c2b6302/code_1.79.0-1686149120_amd64.deb' %}
{% set vscode_hash = 'c629e3cd1bed03ccba0ad43dc6bf995b0e4f053f9553b165161dab9cb68a9990' %}
{% set vscode_tmp = '/tmp/vscode_tmp.deb' %}

{% from "maps/user.jinja" import user with context %}

include:
  - common

fetch_package_vscode:
  cmd.run:
    - name: curl -sSL -o {{ vscode_tmp }} {{ vscode_url }}
    - unless: test -f {{ vscode_tmp }} # don't grab if already grabbed
    - require:
      - pkg: curl

verify_checksum_vscode:
  cmd.run:
    - name: |
        echo {{ vscode_hash }} {{ vscode_tmp }} | sha256sum --check --status
    - require:
      - cmd: fetch_package_vscode
    - prereq:
      - cmd: install_package_vscode

install_package_vscode:
  cmd.run:
    - name: apt-get install -y {{ vscode_tmp }}
    - unless: dpkg -l | grep 'Code editing' # don't rerun if already present

/home/{{ user }}/.config/Code/User/keybindings.json:
  file.managed:
    - source: salt://vscode/keybindings.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 744
    - makedirs: True
    - require:
      - cmd: install_package_vscode

/home/{{ user }}/.config/Code/User/settings.json:
  file.managed:
    - source: salt://vscode/settings.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 744
    - makedirs: True
    - require:
      - cmd: install_package_vscode

{#
  extensions are a pain to install directly with salt so we generate
  a script the user can use to do so
#}
{% set extensions = [
    'golang.go',
    'naumovs.color-highlight',
    'mohsen1.prettify-json',
    'grimmer.vscode-back-forward-button',
    'samuelcolvin.jinjahtml',
    'usernamehw.errorlens',
    'stringham.move-ts',
    'esbenp.prettier-vscode'
] %}
/home/{{ user }}/install_extensions.sh:
  file.managed:
    - source: salt://vscode/install_extensions.sh
    - user: {{ user }}
    - group: {{ user }}
    - mode: 744
    - makedirs: True
    - template: jinja
    - context:
      extensions: {{ extensions }}