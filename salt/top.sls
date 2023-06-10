base:
  '*':
    - baseline
    - users
    - display
    - comfort
    - vscode
    - tools/go
    - tools/nvm

  'docker*':
    - docker
    {# Explicit for now #}
    {# - gui-docker #}

    {# note: docker and gui-docker are explicit #}
