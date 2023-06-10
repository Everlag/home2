kale:
  user.present:
    - home: /home/kale

sudo:
  pkg:
    - installed
  group.present:
    - system: True
    - addusers:
      - kale

docker:
  group.present:
    - system: True
    - addusers:
      - kale

nano:
  pkg:
    - installed

git:
  pkg:
    - installed

p7zip-full:
  pkg:
    - installed

/home/kale/root.sh:
  file.managed:
    - source:
      - salt://root.sh
    - user: kale
    - group: kale
    - mode: 744
