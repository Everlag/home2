## Preparing

There's some steps we need to execute before salt will be able to execute

### prologue: proxmox

IF and only if you're running this on proxmox; drop the licensed repo and adopt the regular

```bash
rm /etc/apt/sources.list.d/pve-enterprise.list
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
```

### general

Then the remaining dependencies before we install the minion

```bash
sudo apt update && sudo apt -y upgrade && sudo apt install -y curl build-essential dkms
# IF non-proxmox
#sudo apt install linux-headers-$(uname -r)
# else, if proxmox
#sudo apt install pve-headers

# if virtualbox
# sudo apt install libxt6 libxmu6
# THEN install guest additions following normal mount + run VBoxLinuxAdditions.run

# install salt minion(edafults to only minion, not master)
curl -o bootstrap-salt.sh -L https://bootstrap.saltproject.io && chmod +x bootstrap-salt.sh && sudo ./bootstrap-salt.sh -P onedir

# ensure minion running
sudo systemctl status salt-minion
```

### salt

Prior to this working, get the contents of the salt directory to `/srv/salt`, probably with a symlink

```bash
# apply critical dependency including minion config
sudo salt-call --local state.apply baseline

# Highstate all configuration
sudo salt-call --local state.apply

./install_extensions.sh # created by vscode state
./load_x_preferences.sh # created by comfort state
```

For docker support
```bash
# docker fun flakiness, requires manual execution and maybe multiple retries
sudo salt-call --local --id=docker-host state.apply.apply docker
```

Then reboot and get into a graphical env using

```bash
startx
```
