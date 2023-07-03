{% set firefox_url = 'https://download-installer.cdn.mozilla.net/pub/firefox/releases/114.0.2/linux-x86_64/en-US/firefox-114.0.2.tar.bz2' %}
{% set firefox_hash = '0cc079b59c37ec2ea2de197931b4ab4173d12bf392f7f2158f63e4326f65b951' %}
{% set firefox_tmp = '/tmp/firefox_tmp.tar.bz2' %}

{# fetch_package_firefox:
  cmd.run:
    - name: curl -sSL -o {{ firefox_tmp }} {{ firefox_url }}
    - unless: test -f {{ firefox_tmp }} # don't grab if already grabbed

verify_checksum_firefox:
  cmd.run:
    - name: |
        echo {{ firefox_hash }} {{ firefox_tmp }} | sha256sum --check --status
    - require:
      - cmd: fetch_package_firefox
    - prereq:
      - cmd: install_package_firefox #}

firefox-prereqs:
  pkg.installed:
    - pkgs:
      - libdbus-glib-1-2

install_package_firefox:
  archive.extracted:
    - name: /srv/
    - source: {{ firefox_url }}
    - source_hash: sha256={{ firefox_hash }}
    - archive_format: tar
    - tar_options: j
    - if_missing: /srv/firefox/
    - require:
        - pkg: firefox-prereqs

link_firefox:
  file.symlink:
    - name: /usr/local/bin/firefox
    - target: /srv/firefox/firefox
    - require:
        - archive: install_package_firefox

{#
  Normally, there'd be a verify step but firefox hates the idea of running as
  root, even for a '--version' check
#}

{# Unclear how to install extensions from cli easily #}