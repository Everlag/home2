{% set user = "kale" %}

xorg:
  pkg:
    - installed

i3:
  pkg:
    - installed
  require:
    - pkg: xorg

rxvt-unicode:
  pkg:
    - installed
  require:
    - pkg: i3

/home/{{ user }}/.xinitrc:
  file.managed:
    - source: salt://display/xinitrc
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True
    - require:
      - pkg: i3