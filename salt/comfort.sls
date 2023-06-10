{% set user = "kale" %}

/home/{{ user }}/.bash_profile:
  file.managed:
    - source: salt://comfort/bash_profile
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True

/home/{{ user }}/.profile:
  file.managed:
    - source: salt://comfort/profile
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True

/home/{{ user }}/.bashrc:
  file.managed:
    - source: salt://comfort/bashrc
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True
    - template: jinja


/home/{{ user }}/.git-prompt:
  file.managed:
    - source: salt://comfort/git-prompt
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True

/home/{{ user }}/.config/i3/config:
  file.managed:
    - source: salt://comfort/i3-config
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True
  cmd.run:
    - name: |
        i3-msg reload
        i3-msg restart

/home/{{ user }}/.Xresources:
  file.managed:
    - source: salt://comfort/Xresources
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True

/home/{{ user }}/.fonts/mononoki-Regular.ttf:
  file.managed:
    - source: salt://comfort/mononoki-Regular.ttf
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True
  cmd.run:
    - name: fc-cache -fv

/home/{{ user }}/.nanorc:
  file.managed:
    - source: salt://comfort/nanorc
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - makedirs: True

/etc/inputrc:
  file.managed:
    - source:
      - salt://comfort/etcinputrc
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644

/home/{{ user }}/.inputrc:
  file.managed:
    - source:
      - salt://comfort/inputrc
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644

/home/{{ user }}/.gitconfig:
  file.managed:
    - source:
      - salt://comfort/gitconfig
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644