```bash
sudo apt update && sudo apt -y upgrade && sudo apt install curl
# install salt minion(edafults to only minion, not master)
curl -o bootstrap-salt.sh -L https://bootstrap.saltproject.io && chmod +x bootstrap-salt.sh && sudo ./bootstrap-salt.sh -P onedir
salt-call --local state.apply baseline # apply critical dependency including minion config

# docker fun flakiness
salt-call --local state.apply.apply docker
salt-call --local state.apply.apply docker
salt-call --local state.apply.apply docker
```