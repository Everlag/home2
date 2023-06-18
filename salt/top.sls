base:
  {# We seed the minion config ONCE, since it requires a specific cli call providing the pillar #}
  "initial-setup":
    - baseline

  '*':
    - users
    - comfort/comfort

  "roles:dev":
    - match: grain
    - display/display
    - vscode/vscode
    - tools/go
    - tools/nvm

  'roles:docker':
    - match: grain
    - docker/docker

  {# valid roles: nebula-ca nebula-node nebula-lighthouse #}
  'roles:nebula':
    - match: grain
    - nebula/nebula

   {# nebula-ca is allowed to sign new certificates #}
  'roles:nebula-ca':
    - match: grain
    - nebula/nebula-ca


  'roles:torrent-vm-host':
    - match: grain
    - vm/torrent_host
  'roles:torrent-vm-guest':
    - match: grain
    - tools/qbittorrent
    {# NOTE: mullvad ALWAYS comes last as it will prevent further network calls until user manually authenticates #}
    - tools/mullvad

    {# note: gui-docker has to be explicit as its flaky and doesn't really have a use yet #}
