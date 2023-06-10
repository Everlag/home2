include:
  - common

kale:
  user.present:
    - home: /home/kale
    - usergroup: True
    - shell: /bin/bash

sudo:
  pkg:
    - installed
  group.present:
    - system: True
    - addusers:
      - kale

docker-group:
  group.present:
    - name: docker
    - system: True
    - addusers:
      - kale

nano:
  pkg:
    - installed

git:
  pkg:
    - installed

/home/kale/root.sh:
  file.managed:
    - source:
      - salt://root.sh
    - user: kale
    - group: kale
    - mode: 744
