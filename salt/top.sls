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
    - tools/qbittorrent
    {# NOTE: mullvad ALWAYS comes last as it will prevent further network calls until user manually authenticates #}
    - tools/mullvad

    {# note: gui-docker has to be explicit as its flaky and doesn't really have a use yet #}
