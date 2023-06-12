set -x

sudo apt update && sudo apt -y upgrade && sudo apt install -y curl build-essential dkms git
curl -o bootstrap-salt.sh -L https://bootstrap.saltproject.io
chmod +x bootstrap-salt.sh 
sudo ./bootstrap-salt.sh -P onedir
sudo systemctl status salt-minion
sudo salt-call --local grains.get ids
git clone https://github.com/everlag/home2
sudo ln -s /home/kale/home2/salt/ /srv/salt
sudo salt-call --local state.apply baseline

echo 'now shutdown and create your template'