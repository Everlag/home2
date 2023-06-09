root:
  user.present:
    - shell: /bin/bash
# TODO: fix ^ so salt doesn't complain...

/etc/salt/minion:
  file.managed:
    - source: salt://minion
    - user: root
    - group: root
    - mode: 644
