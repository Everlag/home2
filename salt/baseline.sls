root:
  user.present:
    - shell: /bin/bash
# TODO: fix ^ so salt doesn't complain...

{% set raw_roles = salt['pillar.get']('SALT_ROLES') %}
{% set salt_roles = raw_roles.split(' ') %}

validate-salt-roles:
  cmd.run:
    {# TODO: figure out how the hell to get these accepted by stateful... #}
    - name: |
      {% if raw_roles|length %}
        exit 0
      {% else %}
        echo {"err\": "\"SALT_ROLES pillar not set, use pillar='{"SALT_ROLES": "potato potato2"}'\"} && exit 1
      {% endif %}
    - stateful: True


/etc/salt/minion:
  file.managed:
    - source: salt://minion
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      salt_roles: {{ salt_roles }}
    - require:
      - cmd: validate-salt-roles