#!/usr/bin/env bash

### Slackware project auto configure

######################### Colors #########################

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

### Options
cyan="$(tput setaf 6)"

### NoColor
nc="$(tput sgr0)"

######################### Starting Installation #########################

## Chroot path
slchroot='/mnt'
##

#######
#clear
sleep 2
echo -e "\n${magentab}Choose the device...${nc}\n"
sleep 2
#######

# Disk select list
hddevsopts="$(lsblk | grep disk | awk '{print $1}')"

for i in $hddevsopts
do
  echo " >>> ${i}"
done
echo
read -p "Choose the device: " hddevselect
if echo "$hddevsopts" | grep "\<$hddevselect\>" > /dev/null 2>&1; then
  hddevselectdev="/dev/$hddevselect"
fi
echo -e "\n${green}Device ${hddevselectdev} selected!!!${nc}"

#######
#clear
sleep 2
echo -e "\n${magentab}Create the partitions...${nc}\n"
sleep 2
#######

if [[ "$(ls /sys/firmware/efi/efivars > /dev/null 2>&1; echo $?)" -eq '0' ]]; then
  echo -e "\n${green}Bios UEFI detected!!!${nc}"
  boot_mode='uefi'
else
  echo -e "\n${green}Bios Legacy detected!!!${nc}"
  boot_mode='legacy'
  echo -e "\n${yellow}Would you like to use MBR or GPT partition scheme?${nc}"
  echo
  read -p "MBR(m) or GPT(g)? " partitionscheme
fi

echo -e "\n${blue}To continue, have the partitions according to the following scheme:${nc}"
sleep 2

if [ "$boot_mode" = 'uefi' ]; then
  echo -e "\n\n${cyan}EFI partition (if it doesn't exist)${nc} ${red}------>${nc} ${cyan}EF00 +512M${nc}"
elif [ "$boot_mode" = 'legacy' ]; then
  if [ "$partitionscheme" = 'M' ] || [ "$partitionscheme" = 'm' ]; then
    echo -e "\n\n${cyan}Bios boot partition${nc} ${red}---------------------->${nc} ${cyan}EF02 +1M${nc}"
    echo -e "\n${cyan}System Boot partition${nc} ${red}-------------------->${nc} ${cyan}8300 +512${nc}"
  elif [ "$partitionscheme" = 'G' ] || [ "$partitionscheme" = 'g' ]; then
    echo -e "\n\n${cyan}System Boot partition${nc} ${red}-------------------->${nc} ${cyan}8300 +512M${nc}"
  fi
fi
echo -e "\n${cyan}Swap partition${nc} ${red}--------------------------->${nc} ${cyan}8200 +(Your ram memory/2)${nc}"
echo -e "\n${cyan}System Root partition${nc} ${red}-------------------->${nc} ${cyan}8300 +(You decide the disk space)${nc}"
sleep 2

echo -e "\n\n${yellow}Would you like to create the partitions with cfdisk?${nc} ${red}(not necessary if they already exist)${nc}"
sleep 2
echo
read -p "Yes(y) or No(n)? " createpartselect
if [ "$createpartselect" = 'Y' ] || [ "$createpartselect" = 'y' ]; then
  echo -e "\n${yellow}Start with an in-memory zeroed partition table?${nc} ${red}('No' for keep partitions scheme)${nc}"
  sleep 2
  echo
  read -p "Yes(y) or No(n)? " zeropartselect
  if [ "$zeropartselect" = 'Y' ] || [ "$zeropartselect" = 'y' ]; then
    sleep 2
    cfdisk -z "$hddevselectdev"
    sync
  elif [ "$zeropartselect" = 'N' ] || [ "$zeropartselect" = 'n' ]; then
    sleep 2
    cfdisk "$hddevselectdev"
    sync
  fi
fi
sleep 2

if [ "$boot_mode" = 'uefi' ] && ! [[ $(fdisk -l "$hddevselectdev" -o type | grep -i 'EFI') ]]; then
  echo -e "\n${red}You are booting in UEFI mode but not EFI partition was created, make sure you select the EFI System type for your EFI partition!!!${nc}"
  sleep 2
  cfdisk "$hddevselectdev"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Set up the partitions...${nc}\n"
sleep 2
#######

echo -e "\n${blue}Now configure the partitions:${nc}"
echo
fdisk -l "$hddevselectdev"
echo
sleep 2
if [ "$boot_mode" = 'uefi' ]; then
  echo -e "\n${blue}Type the EFI partition:${nc}"
  echo
  read -p "--->>> " efi_part
elif [ "$boot_mode" = 'legacy' ]; then
  echo -e "\n${blue}Type the Boot partition:${nc}"
  echo
  read -p "--->>> " boot_part
fi
sleep 2
echo -e "\n${blue}Type the Swap partition (or none):${nc}"
echo
read -p "--->>> " swap_part
sleep 2
echo -e "\n${blue}Type the Root partition:${nc}"
echo
read -p "--->>> " root_part

#######
#clear
sleep 2
echo -e "\n${magentab}Formatting partitions...${nc}\n"
sleep 2
#######

echo -e "\n${yellow}What file system would you like to use?${nc}"
echo -e "\n\n${cyan}--->>> ext4\n\n--->>> xfs\n\n--->>> jfs\n\n--->>> f2fs\n\n--->>> btrfs${nc}"
echo
read -p "Type the filesystem name: " filesystemselect

if [ "$boot_mode" = 'uefi' ]; then
  echo -e "\n${blue}Do you want to format EFI partition?${nc} ${red}(Do not do this if you already have another system installed!!!)${nc}"
  echo
  read -p "Yes(y) or No(n)? " efiformat
  if [ "$efiformat" = 'Y' ] || [ "$efiformat" = 'y' ]; then
    echo
    mkfs.fat -c -F 32 "$efi_part"
  elif [ "$efiformat" = 'N' ] || [ "$efiformat" = 'n' ]; then
    echo -e "\n${green}Not formatting EFI partition!!!${nc}"
  fi
elif [ "$boot_mode" = 'legacy' ]; then
  echo
  if [ "$filesystemselect" = 'ext4' ] || [ "$filesystemselect" = 'xfs' ] || [ "$filesystemselect" = 'jfs' ] || [ "$filesystemselect" = 'f2fs' ]; then
    mkfs.ext4 -c -F "$boot_part"
  elif [ "$filesystemselect" = 'btrfs' ]; then
    mkfs.btrfs -f "$boot_part"
  fi
fi
echo
if [ "$swap_part" != 'none' ]; then
  echo -e "\n${blue}Do you want check for badblocks when formatting Swap partition?${nc} ${red}(This take time on HDD!!!)${nc}"
  echo
  read -p "Yes(y) or No(n)? " swapcheck
  echo
  if [ "$swapcheck" = 'Y' ] || [ "$swapcheck" = 'y' ]; then
    mkswap -c "$swap_part"
  else
    mkswap "$swap_part"
  fi
  swapon "$swap_part"
fi
echo
echo -e "\n${blue}Do you want check for badblocks when formatting Root partition?${nc} ${red}(This take time on HDD!!!)${nc}"
echo
read -p "Yes(y) or No(n)? " rootcheck
if [ "$filesystemselect" = 'ext4' ]; then
  if [ "$rootcheck" = 'Y' ] || [ "$rootcheck" = 'y' ]; then
    mkfs.ext4 -c -L "Slackware" -F "$root_part"
  else
    mkfs.ext4 -L "Slackware" -F "$root_part"
  fi
elif [ "$filesystemselect" = 'xfs' ]; then
  mkfs.xfs -L "Slackware" -f "$root_part"
elif [ "$filesystemselect" = 'jfs' ]; then
  if [ "$rootcheck" = 'Y' ] || [ "$rootcheck" = 'y' ]; then
    mkfs.jfs -q -c -L "Slackware" "$root_part"
  else
    mkfs.jfs -q -L "Slackware" "$root_part"
  fi
elif [ "$filesystemselect" = 'f2fs' ]; then
  mkfs.f2fs -l "Slackware" -f "$root_part"
elif [ "$filesystemselect" = 'btrfs' ]; then
  mkfs.btrfs -L "Slackware" -f "$root_part"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring mount points and mounting partitions...${nc}\n"
sleep 2
#######

if [[ $(lsblk -d -o name,rota | grep "$hddevselect" > /dev/null 2>&1) = '0' ]]; then
  install_disk='ssd'
fi

if [[ $(ls "$slchroot" > /dev/null 2>&1) = "$slchroot" ]]; then
  echo -e "\n${green}Directory $slchroot detected!!!${nc}"
  sleep 2
else
  echo -e "\n${green}Directory $slchroot not detected!!!\nCreating it...${nc}"
  sleep 2
  mkdir -p "$slchroot"
fi

if [ "$filesystemselect" = 'ext4' ] || [ "$filesystemselect" = 'xfs' ] || \
[ "$filesystemselect" = 'jfs' ] || [ "$filesystemselect" = 'f2fs' ]; then
  if [ "$boot_mode" = 'uefi' ]; then
    mount "$root_part" "$slchroot"
  else
    mount "$root_part" "$slchroot"
    mkdir -p "$slchroot/boot"
    mount "$boot_part" "$slchroot/boot"
  fi
elif [ "$filesystemselect" = 'btrfs' ]; then
  mount "$root_part" "$slchroot"
  if [ "$install_disk" = 'ssd' ]; then
    if [ "$boot_mode" = 'uefi' ]; then
      btrfs subvol create "$slchroot/@"
      btrfs subvol create "$slchroot/@home"
      btrfs subvol create "$slchroot/@snapshots"
      btrfs subvol create "$slchroot/@var_log"
      umount -lR "$slchroot"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@ "$root_part" "$slchroot"
      mkdir -p "$slchroot"/{efi,home,.snapshots,var/log}
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@home "$root_part" "$slchroot/home"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@snapshots "$root_part" "$slchroot/.snapshots"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@var_log "$root_part" "$slchroot/var/log"
      mount "$efi_part" "$slchroot/efi"
    elif [ "$boot_mode" = 'legacy' ]; then
      btrfs subvol create "$slchroot/@"
      btrfs subvol create "$slchroot/@home"
      btrfs subvol create "$slchroot/@snapshots"
      btrfs subvol create "$slchroot/@var_log"
      umount -lR "$slchroot"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@ "$root_part" "$slchroot"
      mkdir -p "$slchroot"/{boot,home,.snapshots,var/log}
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd "$boot_part" "$slchroot/boot"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@home "$root_part" "$slchroot/home"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@snapshots "$root_part" "$slchroot/.snapshots"
      mount -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@var_log "$root_part" "$slchroot/var/log"
    fi
  else
    if [ "$boot_mode" = 'uefi' ]; then
      btrfs subvol create "$slchroot/@"
      btrfs subvol create "$slchroot/@home"
      btrfs subvol create "$slchroot/@snapshots"
      btrfs subvol create "$slchroot/@var_log"
      umount -lR "$slchroot"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@ "$root_part" "$slchroot"
      mkdir -p "$slchroot"/{efi,home,.snapshots,var/log}
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@home "$root_part" "$slchroot/home"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@snapshots "$root_part" "$slchroot/.snapshots"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@var_log "$root_part" "$slchroot/var/log"
      mount "$efi_part" "$slchroot/efi"
    elif [ "$boot_mode" = 'legacy' ]; then
      btrfs subvol create "$slchroot/@"
      btrfs subvol create "$slchroot/@home"
      btrfs subvol create "$slchroot/@snapshots"
      btrfs subvol create "$slchroot/@var_log"
      umount -lR "$slchroot"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@ "$root_part" "$slchroot"
      mkdir -p "$slchroot"/{boot,home,.snapshots,var/log}
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd "$boot_part" "$slchroot/boot"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@home "$root_part" "$slchroot/home"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@snapshots "$root_part" "$slchroot/.snapshots"
      mount -t btrfs -o defaults,noatime,autodefrag,compress=zstd,subvol=@var_log "$root_part" "$slchroot/var/log"
    fi
  fi
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Generating fstab...${nc}\n"
sleep 2
#######

# Download genfstab and apply exec permission
wget https://raw.githubusercontent.com/glacion/genfstab/refs/heads/master/genfstab
chmod +x genfstab

# Create new file
echo -e "### File generated by genfstab\n" > "$glchroot/etc/fstab"

if [ "$boot_mode" = 'uefi' ]; then
  ./genfstab -U "$glchroot" >> "$glchroot/etc/fstab"
elif [ "$boot_mode" = 'legacy' ]; then
  ./genfstab -L "$glchroot" >> "$glchroot/etc/fstab"
fi

# remove subvolid for work with snapshots
if [ "$filesystemselect" = 'btrfs' ]; then
  sed -i 's/,subvolid=\<[0-9]*\>//g' "$glchroot/etc/fstab"
fi

# Delete file
rm genfstab

#######
#clear
sleep 2
echo -e "\n${magentab}Executing final check...${nc}\n"
sleep 2
#######


btrfs subvol list "$slchroot"
echo
df -ah | grep "${hddevselectdev}"

echo -e "\n${yellow}All Okay???${nc}"
  sleep 2
  echo
  read -p "Yes(y) or No(n)? " finalcheck
  if [ "$finalcheck" = 'Y' ] || [ "$finalcheck" = 'y' ]; then
    sleep 2
    echo -e "\n${green}Procedding...${nc}"
  elif [ "$finalcheck" = 'N' ] || [ "$finalcheck" = 'n' ]; then
    sleep 2
    echo -e "\n${red}Please restart this script to correct your disk configuration...${nc}"
    umount -lR "${hddevselectdev}"
    exit
  fi
fi

#######
#clear
sleep 2
echo -e "\n${magentab}All ok there, now run 'setup' to start the installation!!!${nc}\n"
sleep 3
#######
