base:
  'setup':
    - baseline
    - users
    - display/display
    - comfort/comfort
    - vscode/vscode
    - tools/go
    - tools/nvm

  'docker*':
    - docker/docker


  'torrent-vm-host*':
    - vm/torrent_host
  'torrent-vm-guest*':
    - tools/mullvad
    {# Explicit for now #}
    {# - gui-docker #}

    {# note: docker and gui-docker are explicit #}
