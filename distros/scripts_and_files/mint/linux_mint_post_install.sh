#!/bin/bash

## Pre-check if UEFI is available
if [[ "$(ls /sys/firmware/efi/efivars > /dev/null 2>&1; echo $?)" -eq '0' ]]
then
  boot_mode='uefi'
fi

### Start

clear

## Set timeout grub for 10 seconds
su root -c 'echo -e "\n# Fix grub timeout\nGRUB_RECORDFAIL_TIMEOUT=10" >> /etc/default/grub.d/50_linuxmint.cfg'

## Install linux mint grub theme
read -p "This pc/notebook is using an HiDPI screen? [Yes/No] " hidpiask
echo
if [ "$hidpiask" = 'Yes' ] || [ "$hidpiask" = 'yes' ] || [ "$hidpiask" = 'YES' ] || [ "$hidpiask" = 'Y' ] || [ "$hidpiask" = 'y' ]
then
    apt -y install --reinstall -o Dpkg::Options::="--force-confmiss" grub2-theme-mint-2k
elif [ "$hidpiask" = 'No' ] || [ "$hidpiask" = 'no' ] || [ "$hidpiask" = 'NO' ] || [ "$hidpiask" = 'N' ] || [ "$hidpiask" = 'n' ]
then
    apt -y install --reinstall -o Dpkg::Options::="--force-confmiss" grub2-theme-mint
fi
echo

## Install necessary deps
sudo apt -y install build-essential git inotify-tools
echo

## Download, install and configure grub-btrfs
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
# cleaning
cd ..
rm -rf grub-btrfs
echo
# configure grub-btrfsd.service
sudo sed -i 's,/.snapshots,--timeshift-auto,' /lib/systemd/system/grub-btrfsd.service
# enable grub-btrfsd.service
sudo systemctl enable grub-btrfsd
echo

## Download, install and configure timeshift-autosnap-apt
git clone https://github.com/wmutschl/timeshift-autosnap-apt.git
cd timeshift-autosnap-apt
sudo make install
# cleaning
cd ..
rm -rf timeshift-autosnap-apt
echo
# configure timeshift-autosnap-apt
read -p "This system is using a dedicated /boot partition? [Yes/No] " bootpartask
if [ "$bootpartask" = 'No' ] || [ "$bootpartask" = 'no' ] || [ "$bootpartask" = 'NO' ] || [ "$bootpartask" = 'N' ] || [ "$bootpartask" = 'n' ]
then
    sudo sed -i 's,snapshotBoot=true,snapshotBoot=false,' /etc/timeshift-autosnap-apt.conf
fi
if [ "$boot_mode" != 'uefi' ]
then
    sudo sed -i 's,snapshotEFI=true,snapshotEFI=false,' /etc/timeshift-autosnap-apt.conf
fi
echo

## Update grub config file
sudo update-grub

echo
echo "All Ok, Linux Mint configured! Thanks!"
