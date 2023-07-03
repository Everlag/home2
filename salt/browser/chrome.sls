chrome-deps:
  pkg.installed:
    - pkgs:
      - gnupg
      - curl
      - ca-certificates
      - apt-transport-https

chrome-repo:
  cmd.run:
    - name: |
        curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
        echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
        apt-get update
    - unless: test -f /etc/apt/sources.list.d/google.list
    - require:
      - pkg: chrome-deps

google-chrome-stable:
  pkg.installed:
    - require:
      - cmd: chrome-repo

chrome-verify:
  cmd.run:
    - name: google-chrome --version > /dev/null
    - stateful: True
    - require:
      - pkg: google-chrome-stable
      

{% set chrome_ext_prefs = "/opt/google/chrome/extensions" %}
{% set chrome_ext_remote = "https://clients2.google.com/service/update2/crx" %}
{% set chrome_extensions = {
  "vimium": "dbepggeogbaibhgnhhndojpepiihcmeb",
  "ublockorigin": "cjpalhdlnbpafiamejdnhcphjbkeiagm",
  "tabsessionmanager": "iaiomicjabeggjcfkbimgmglanimpnae"
} %}

{{ chrome_ext_prefs }}:
  file.directory:
    - name: {{ chrome_ext_prefs }}
    - user: root
    - group: root
    - dir_mode: 775
    - file_mode: 666
    - require:
      - cmd: chrome-verify

{% for ext in chrome_extensions %}

{% set ext_file = chrome_ext_prefs + "/" + chrome_extensions[ext] + ".json" %}
chrome_extension_{{ ext }}:
  cmd.run:
    - name: |
        echo '{"external_update_url": "{{ chrome_ext_remote }}"}' > {{ ext_file }}
    - unless: test -f {{ ext_file }}
    - require:
      - file: {{ chrome_ext_prefs }}
{% endfor %}