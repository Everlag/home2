xorg:
  pkg:
    - installed

i3:
  pkg:
    - installed
  require:
    - pkg: xorg