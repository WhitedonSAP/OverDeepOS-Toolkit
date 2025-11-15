#!/usr/bin/env bash
#######################################################################################
#                                                                                     #
#  chroot.sh - for use with linux systems                                             #
#                                                                                     #
#  By                                                                                 #
#  WhitedonSAP                                                                        #
#                                                                                     #
#  E-mail - ayrtonarantes0987654321ayrt008@gmail.com                                  #
#  Telegram - https://t.me/WhitedonSAP                                                #
#                                                                                     #
#######################################################################################

#################################### Colors ###########################################

### Advices/Errors
red="$(tput setaf 1)"

### Confirms/Success
green="$(tput setaf 2)"

### Questions
yellow="$(tput setaf 3)"

### Default Text
blue="$(tput setaf 4)"

### Steps
magentab="$(tput bold ; tput setaf 5)"

### Nocolor
nc="$(tput sgr0)"

################################ Script variables #####################################

### Chroot path
glchroot='/mnt/gentoo'

### Check if Bios UEFI or Bios Legacy is actived
efivars="$(ls /sys/firmware/efi/efivars > /dev/null 2>&1; echo $?)"

### Set the EFI partition
efibootmode1="$(blkid -s LABEL | grep -w 'EFI' | awk '{print $1}' | sed 's/.$//')"
efibootmode2="$(blkid -s TYPE | grep -w 'vfat' | awk '{print $1}' | sed 's/.$//')"

### Set the Boot partition (if bios="legacy")
legacybootmode="$(blkid -s LABEL | grep -w 'BOOT' | awk '{print $1}' | sed 's/.$//')"

### Set the Root partition:
rootpartselect="$(blkid -s LABEL | grep -w 'Gentoo Linux' | awk '{print $1}' | sed 's/.$//')"

################################ Starting Script ######################################

#######
clear
sleep 2
echo -e "\n${magentab}Scanning partitions...${nc}\n"
sleep 2
#######

if [ "$efivars" -eq '0' ]
then
    boot_mode="uefi"
    echo -e "\n${green}Bios UEFI detected!!!${nc}"
else
    boot_mode="legacy"
    echo -e "\n${green}Bios Legacy detected!!!${nc}"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Mounting the System...${nc}\n"
sleep 2
#######

if [[ $(find "$glchroot" > /dev/null 2>&1) != "" ]]; then
    echo -e "\n${green}Directory $glchroot detected!!!${nc}"
    sleep 2
else
    echo -e "\n${green}Directory $glchroot not detected!!!\nCreating it...${nc}"
    sleep 2
    mkdir -p "$glchroot"
fi

echo -e "\n${blue}Scanning filesystems...${nc}\n"
sleep 2

if [[ $(blkid | grep "Gentoo Linux" | grep 'TYPE="btrfs"') != "" ]]; then
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@ "$rootpartselect" "$glchroot"
    if [ "$boot_mode" = 'uefi' ]; then
        mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@boot "$rootpartselect" "$glchroot/boot"
    elif [ "$boot_mode" = 'legacy' ]; then
        mount -t btrfs -o defaults,noatime,compress=zstd "$legacybootmode" "$glchroot/boot"
    fi
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@home "$rootpartselect" "$glchroot/home"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@root "$rootpartselect" "$glchroot/root"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@snapshots "$rootpartselect" "$glchroot/snapshots"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@srv "$rootpartselect" "$glchroot/srv"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@log "$rootpartselect" "$glchroot/var/log"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@cache "$rootpartselect" "$glchroot/var/cache"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@tmp "$rootpartselect" "$glchroot/tmp"
else
    mount "$rootpartselect" "$glchroot"
fi

if [ "$boot_mode" = 'uefi' ]; then
    if [ "$efibootmode1" != '' ]; then
        mount "$efibootmode1" "$glchroot/boot/efi"
    elif [ "$efibootmode2" != '' ]; then
        mount "$efibootmode2" "$glchroot/boot/efi"
    fi
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Checking the init system...${nc}\n"
sleep 2
#######

if [[ $(find "$glchroot/sbin/openrc-init" > /dev/null 2>&1) != "" ]]; then
    system_init="openrc"
    echo -e "\n${green}OpenRC-init detected!!!${nc}"
else
    system_init="systemd"
    echo -e "\n${green}Systemd-init detected!!!${nc}"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Chrooting...${nc}\n"
sleep 2
#######

if [ "$system_init" = 'openrc' ]; then
    mount --types proc /proc "$glchroot/proc"
    mount --rbind /sys "$glchroot/sys"
    mount --rbind /dev "$glchroot/dev"
    mount --bind /run "$glchroot/run"
elif [ "$system_init" = 'systemd' ]; then
    mount --types proc /proc "$glchroot/proc"
    mount --rbind /sys "$glchroot/sys"
    mount --make-rslave "$glchroot/sys"
    mount --rbind /dev "$glchroot/dev"
    mount --make-rslave "$glchroot/dev"
    mount --bind /run "$glchroot/run"
    mount --make-slave "$glchroot/run"
fi

echo -e "\n${yellow}Chroot now?${nc} ${red}(You can do this later)${nc}"
sleep 2
echo
read -p "Yes(y) or No(n)? " chnow
if [ "$chnow" = 'N' ] || [ "$chnow" = 'n' ]; then
    sleep 2
    echo -e "\n${blue}Execute at any time:${nc}\n\n${green}chroot $glchroot /bin/bash${nc}\n\n${blue}and${nc}\n\n${green}source /etc/profile${nc}\n\n${blue}Have fun!!!${nc}\n"
    exit
fi

#######
#clear
sleep 2
echo -e "\n${blue}All Ok, now execute:${nc}\n\n${green}source /etc/profile${nc}\n\n${blue}And have fun!!!${nc}\n"
sleep 2
#######

chroot "$glchroot" /bin/bash
