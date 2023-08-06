{# TODO; why does this cause issues? I guess rely on top.sls... #}
{# include:
  - common
  - nebula/nebula_bin #}

{% set nebula_ca_location = "/etc/nebula-ca" %}
{% set nebula_keys_location = "/etc/nebula-ca/keys" %}

{% from "maps/nebula.jinja" import nebula_ca, nebula_hosts, nebula_certpack_password with context %}

nebula_ca:
    cmd.run:
      - name: |
          mkdir -p {{ nebula_ca_location }}
          chmod -R 600 {{ nebula_ca_location }}
          cd {{ nebula_ca_location }}
          nebula-cert ca -name "{{ nebula_ca['name'] }}" -duration 190800h
      - unless: test -f {{ nebula_ca_location }}/ca.crt && test -f {{ nebula_ca_location }}/ca.key # don't overwrite existing

{# Ensure our configured cert matches at least our network name #}
verify_nebula_ca:
    cmd.run:
      - name: |
          nebula-cert print -json -path {{ nebula_ca_location }}/ca.crt | grep -q {{ nebula_ca['name'] }} || echo 'err="ca cert unexpected name"'
      - stateful: True
      - require:
          - cmd: nebula_ca

{{ nebula_keys_location }}:
  file.directory:
    - user: root
    - group: root
    - mode: 600
    - makedirs: True
    - require:
        - cmd: verify_nebula_ca

{# Now sign everything; we don't sign if those already exist #}
{% for host in nebula_hosts %}
sign_{{ host['name'] }}:
  cmd.run:
    - name: |
        cd {{ nebula_keys_location }}
        nebula-cert sign -name "{{ host['name'] }}" -ip {{ host['ip'] }} -duration 8760h -ca-crt {{ nebula_ca_location }}/ca.crt -ca-key {{ nebula_ca_location }}/ca.key -groups "{{ host['groups']|join(',') }}"
    - unless: test -f {{ nebula_keys_location }}/{{host['name']}}.crt && test -f {{ nebula_keys_location }}/{{host['name']}}.key # don't overwrite existing
    - require:
        - cmd: verify_nebula_ca
        - file: {{ nebula_keys_location }}

{# Verify the certs we have are consistent and in good standing #}
verify_signed_{{ host['name'] }}:
  cmd.run:
    - name: |
        nebula-cert verify -ca {{ nebula_ca_location }}/ca.crt -crt {{ nebula_keys_location }}/{{host['name']}}.crt
    - stateful: True
    - require:
        - cmd: sign_{{ host['name'] }}

{# Zip up the cert packs for shipping around; include everything we need #}
nebula_cert_pack_{{ host['name'] }}:
  cmd.run:
    - name: |
        cd {{ nebula_keys_location }}
        7z a {{ host['name'] }}.7z {{host['name']}}.crt {{host['name']}}.key ../ca.crt -p{{ nebula_certpack_password }}
    - unless: test -f {{ nebula_keys_location }}/{{ host['name'] }}.7z
    - require:
        - cmd: verify_signed_{{ host['name'] }}

{# base64 the certpacks for easy copy-paste #}
nebula_cert_pack_b64_{{ host['name'] }}:
  cmd.run:
    - name: |
        cd {{ nebula_keys_location }}
        cat {{ host['name'] }}.7z | base64 --wrap 0 > {{ host['name'] }}.b64
    - unless: test -f {{ nebula_keys_location }}/{{ host['name'] }}.b64
    - require:
        - cmd: nebula_cert_pack_{{ host['name'] }}
{% endfor %}