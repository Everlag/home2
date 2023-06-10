{# base install: https://gist.github.com/ScriptAutomate/77775f26c6640d184b0574065ff94d64 #}
# Created this state as part of the following:
# PR on salt-jenkins: https://github.com/saltstack/salt-jenkins/pull/1714
# Related issue in salt: https://github.com/saltstack/salt/issues/60605
{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

docker-prereqs:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release

# Workaround for pkgrepo bug
docker-repo-workaround:
  cmd.run:
    - name: |
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch={{ grains['osarch'] }} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    - unless: docker --version || true # don't try to do this twice
    - require:
      - docker-prereqs

/sys/fs/cgroup/systemd:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
  cmd.run:
    - name: mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
    - unless: findmnt /sys/fs/cgroup/systemd | grep cgroup # don't double-mount

# SUSE, Fedora, Photon, and more install Docker from OS distro repos
docker:
  pkg.installed:
    - refresh: True
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - require:
      - cmd: docker-repo-workaround
      - cmd: /sys/fs/cgroup/systemd
    - aggregate: False

curl:
  pkg.installed:
    - names:
      - curl

{% set sysbox_url = 'https://downloads.nestybox.com/sysbox/releases/v0.6.1/sysbox-ce_0.6.1-0.linux_amd64.deb' %}
{% set sysbox_hash = 'd57dc297c60902d4f7316e4f641af00a2a9424e24dde88bb2bb7d3bc419b0f04' %}
{% set sysbox_tmp = '/tmp/sysbox_tmp.deb' %}

fetch_package_sysbox:
  cmd.run:
    - name: curl -sSL -o {{ sysbox_tmp }} {{ sysbox_url }}
    - unless: test -f {{ sysbox_tmp }} # don't grab if already grabbed
    - require:
      - pkg: curl
      - pkg: docker

verify_checksum_sysbox:
  cmd.run:
    - name: |
        echo {{ sysbox_hash }} {{ sysbox_tmp }} | sha256sum --check --status
    - require:
      - cmd: fetch_package_sysbox
    - prereq:
      - cmd: install_package_sysbox

purge_existing_containers:
  {# kill all containers as that will prevent sysbox clean install #}
  cmd.run:
    - name: docker rm -f $(docker ps -a -q)
    - require:
      - pkg: docker

{# apt fails to find docker for setup... no idea why, so we use dpkg explicitly #}
install_package_sysbox:
  cmd.run:
    - name: dpkg -i {{ sysbox_tmp }}
    - unless: dpkg -l | grep sysbox-ce # don't rerun if already present
    - require:
      - pkg: docker
      - cmd: purge_existing_containers

verify_sysbox:
  cmd.run:
    - name: docker run --runtime=sysbox-runc hello-world
    - require:
      - cmd: install_package_sysbox