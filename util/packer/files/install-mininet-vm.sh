#!/bin/bash

REMOTE="git://github.com/mininet/mininet"
DIR="/home/mininet/mininet"
REF=""

while getopts ":d:r:c:h" opt; do
  case $opt in
    r) REMOTE=${OPTARG} ;;
    d) DIR=${OPTARG} ;;
    c) REF=${OPTARG} ;;
    h)
      help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo >&2
      help >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo >&2
      help >&2
      exit 1
      ;;
  esac
done

help() {
  echo "Usage: `basename $0` options [-r remote] [-d repository_dir] [-c checkout_ref] [-h]"
}


if [ "$(id -nu)" -ne 'mininet']; then
  if ! id mininet; then
    sudo useradd --comment 'mininet' --user-group --create-home --shell='/bin/bash' mininet
  fi

  grep "mininet" /etc/sudoers || \
    echo "mininet ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null

  chown -R mininet:mininet ~mininet/

  # Run the rest of this script as the mininet user
  exec sudo mininet "$0" "$@"
fi

# This script is intended to install Mininet into
# a brand-new Ubuntu virtual machine,
# to create a fully usable "tutorial" VM.
#
# optional argument: Mininet branch to install
set -e
sudo sed -i -e 's/Default/#Default/' /etc/sudoers

# Cloud-init can set the hostname
#echo mininet-vm | sudo tee /etc/hostname > /dev/null
#sudo sed -i -e 's/ubuntu/mininet-vm/g' /etc/hosts
#sudo hostname `cat /etc/hostname`

sudo sed -i -e 's/splash//' /etc/default/grub
sudo sed -i -e 's/quiet/text/' /etc/default/grub
sudo update-grub
# Update from official archive
sudo apt-get update
# 12.10 and earlier
#sudo sed -i -e 's/us.archive.ubuntu.com/mirrors.kernel.org/' \
#	/etc/apt/sources.list
# 13.04 and later
#sudo sed -i -e 's/\/archive.ubuntu.com/\/mirrors.kernel.org/' \
#	/etc/apt/sources.list
# Clean up vmware easy install junk if present
if [ -e /etc/issue.backup ]; then
    sudo mv /etc/issue.backup /etc/issue
fi
if [ -e /etc/rc.local.backup ]; then
    sudo mv /etc/rc.local.backup /etc/rc.local
fi
sudo apt-get -y install git-core openssh-server

if ! git -C "${DIR}" status 2>/dev/null 2>&1; then
  # Fetch Mininet
  git clone "${REMOTE}" "${DIR}"
fi

# Optionally check out branch
if [ -z "${REF}" ]; then
  # Repository will in detached HEAD state if REF
  # is anything but a branch. This is fine unless
  # you want to commit changes.
  git -C "${DIR}" checkout "${REF}"
fi

# Install Mininet
time "${DIR}/util/install.sh"

# Finalize VM
# Disable -d for now; causes problems for packer. 
#time "${DIR}/util/install.sh" -tcd
time "${DIR}/util/install.sh" -tc
# Ignoring this since NOX classic is deprecated
#if ! grep NOX_CORE_DIR .bashrc; then
#  echo "export NOX_CORE_DIR=~/noxcore/build/src/" >> .bashrc
#fi
echo "Done preparing Mininet VM."
