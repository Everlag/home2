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

Prior to this working, get the contents of the salt directory to `/srv/salt`, probably with a symlink.

**Confirm /srv/salt has this README.md within before proceeding**

Note: we use the minion id in a hacky manner

First, initialize our salt minion file with the desired roles.
Check the `top.sls` file to see what roles a given server should have.

```bash
# apply critical dependency including minion config
#
# NOTE: the SALT_ROLES here controls what states will be applied
# and how that state will be rendered(ie, for nebula config if applicable)
sudo salt-call --local --id=initial-setup state.apply baseline pillar='{"SALT_ROLES": "role1 role2 role3", "NEBULA_HOSTNAME": "$NEBULA_HOSTNAME"}
```

```bash

# Highstate all configuration

sudo salt-call --local state.apply

# Present depending on enabled roles.
./install_extensions.sh # created by vscode state
./load_x_preferences.sh # created by comfort state
```

For docker support

```bash
# docker fun flakiness, requires manual execution and maybe multiple retries
sudo salt-call --local state.apply.apply docker
```

Then reboot and get into a graphical env using

```bash
startx
```

# Initializing a VM base template

Proxmox base templates are easy to initialize; this generates an image that has salt-minion installed and the `baseline` state having been run.

1. boot up a debian image(11 is a known good version) as a fresh VM
1. run `vm/initialize_base_image.sh` within the fresh VM
1. shutdown and create template

```

```
