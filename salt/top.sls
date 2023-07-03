base:
  {#
    We seed the minion config ONCE, since it requires a specific cli call providing the pillar
    Hence, we cheat and override the minion ID to ensure this is run only on-demand
  #}
  "initial-setup":
    - baseline

  {# '*':
    - users
    - comfort/comfort #}

  "roles:dev":
    - match: grain
    - display/display
    - vscode/vscode
    - tools/go
    - tools/nvm

  "roles:browser":
    - match: grain
    - browser/chrome
    {# - browser/firefox #}

  'roles:docker':
    - match: grain
    - docker/docker

  {# includes lighthouses #}
  'roles:nebula-node':
    - match: grain
    - common
    - nebula/nebula_bin
    - nebula/nebula-node

   {# nebula-ca is allowed to sign new certificates #}
  'roles:nebula-ca':
    - match: grain
    - common
    - nebula/nebula_bin
    - nebula/nebula-ca

  'roles:vm-host':
    - match: grain
    {# TODO: this just notes existence #}

  'roles:torrent-vm-host':
    - match: grain
    - vm/torrent_host
  'roles:torrent-vm-guest':
    - match: grain
    - tools/qbittorrent
    {# NOTE: mullvad ALWAYS comes last as it will prevent further network calls until user manually authenticates #}
    - tools/mullvad

    {# note: gui-docker has to be explicit as its flaky and doesn't really have a use yet #}
