#!/usr/bin/env bash
######################################################################################
#                                                                                    #
#  overdeep-installer - Official installer for Overdeep OS and others Distros Linux  #
#                                                                                    #
#  By                                                                                #
#  WhitedonSAP                                                                       #
#                                                                                    #
#  E-mail - ayrtonarantes0987654321ayrt008@gmail.com                                 #
#  Telegram - https://t.me/WhitedonSAP                                               #
#                                                                                    #
######################################################################################

# overdeep-installer version
VERSION='0.0.1 (alpha)'

# actual path
BASEDIR="$(dirname "$0")"

# path to overdeep-installer
#OVERDEEP_PATH="$BASEDIR"

# directory of /mnt to work
CHROOT='/mnt/overdeep'

# true / false
TRUE=0
FALSE=1

# return codes
SUCCESS=0
FAILURE=1

# colors
#BLACK="$(tput setaf 0)"
#BLACKB="$(tput bold ; tput setaf 0)"
RED="$(tput setaf 1)"
#REDB="$(tput bold ; tput setaf 1)"
GREEN="$(tput setaf 2)"
#GREENB="$(tput bold ; tput setaf 2)"
YELLOW="$(tput setaf 3)"
#YELLOWB="$(tput bold ; tput setaf 3)"
BLUE="$(tput setaf 4)"
BLUEB="$(tput bold ; tput setaf 4)"
#MAGENTA="$(tput setaf 5)"
MAGENTAB="$(tput bold ; tput setaf 5)"
#CYAN="$(tput setaf 6)"
#CYANB="$(tput bold ; tput setaf 6)"
WHITE="$(tput setaf 7)"
#WHITEB="$(tput bold ; tput setaf 7)"
BLINK="$(tput blink)"
NC="$(tput sgr0)"

# check boot mode
BOOT_MODE=''

# installer opts
# installation mode
INSTALL_MODE=''
# current running system
SYSTEM_BASED=''
# init system for install
INIT_SYSTEM=''
# verbose mode
VERBOSE=''
# default locale
DEF_LOCALE='en_US.UTF-8'
# chosen locale
LOCALE=''
# default keymap
DEF_KEYMAP='us'
# chosen keymap
KEYMAP=''
# hostname
HOST_NAME=''
# dualboot flag
DUALBOOT=''
# luks flag
LUKS=''

# network opts
# network interfaces
NET_IFS=''
# chosen network interface
NET_IF=''
# network configuration mode
NET_CONF_MODE=''
# network configuration modes
NET_CONF_AUTO='1'
NET_CONF_WLAN='2'
NET_CONF_MANUAL='3'
NET_CONF_SKIP='4'
# host ipv4 address
HOST_IPV4=''
# gateway ipv4 address
GATEWAY=''
# subnet mask
SUBNETMASK=''
# broadcast address
BROADCAST=''
# nameserver address
NAMESERVER=''
# wlan ssid
WLAN_SSID=''
# wlan passphrase
WLAN_PASSPHRASE=''

# disks and bios
# available hard drive
HD_DEVS=''
# chosen hard drive device
HD_DEV=''
# partitions
PARTITIONS=''
# partition label: gpt or dos
PART_LABEL=''
# efi partition (if bios uefi)
EFI_PART=''
# boot partition
BOOT_PART=''
# root partition
ROOT_PART=''
# crypted root
CRYPT_ROOT='r00t'
# swap partition
SWAP_PART=''
# boot fs type - default: ext4
BOOT_FS_TYPE=''
# root fs type - default: ext4
ROOT_FS_TYPE=''
# create subvol on btrfs
BTRFS_SUBVOL=$TRUE

# current system opts
CUR_INIT_SYSTEM=''

# xorg/wayland (display + de/wm ) setup - default: false
DISPLAY_SERVER_SETUP=$FALSE

# vms opts
# virtualBox setup - default: false
VBOX_SETUP=$FALSE
# vmware setup - default: false
VMWARE_SETUP=$FALSE

# post install
# normal system user
NORMAL_USER=''

# default Overdeep OS repository URL
ARCHLINUX_REPO_URL=''

# exit on ctrl + c
ctrl_c()
{
    echo
    err "Keyboard Interrupt detected, leaving..."
    exit $FAILURE
}
trap ctrl_c 2


# check exit status
check()
{
    es=$1
    func="$2"
    info="$3"

    if [ "$es" -ne 0 ]
    then
        echo
        warn "Something went wrong with $func. $info."
        sleep 5
    fi
}


# window default output
woutput()
{
    wout="${1}"

    shift
    printf "%s$wout%s" "$WHITE" "$@" "$NC"

    return $SUCCESS
}


# print warning
warn()
{
    echo
    printf "%s[!] WARNING: %s%s\n" "$YELLOW" "$@" "$NC"
    echo
    sleep 3

    return $SUCCESS
}


# print error and return failure
err()
{
    echo
    printf "%s[-] ERROR: %s%s\n" "$RED" "$@" "$NC"
    echo
    sleep 3

    return $FAILURE
}


# print success
okay()
{
    echo
    printf "%s[!] SUCCESS: %s%s\n" "$GREEN" "$@" "$NC"
    echo
    sleep 2

    return $SUCCESS
}


# leet banner
banner()
{
    columns="$(tput cols)"
    str="--==[ overdeep-installer v$VERSION ]==--"

    printf "${MAGENTAB}%*s${NC}\n" "${COLUMNS:-$(tput cols)}" | tr ' ' '-'

    echo "$str" |
    while IFS= read -r line
    do
        printf "%s%*s\n%s" "$BLUEB" $(( (${#line} + columns) / 2)) \
        "$line" "$NC"
    done

    printf "${MAGENTAB}%*s${NC}\n\n\n" "${COLUMNS:-$(tput cols)}" | tr ' ' '-'

    return $SUCCESS
}


# sleep and clear
sleep_clear()
{
    sleep "$1"
    clear

    return $SUCCESS
}


# confirm user inputted yYnN
confirm()
{
    ask="$1"

    while true
    do
        woutput "$ask"
        read -r input
        case $input in
            y|Y|yes|YES|Yes) return $TRUE ;;
            n|N|no|NO|No) return $FALSE ;;
            *) err 'Incorrect option! Try again...' ; sleep 2 ; clear ; continue ;;
        esac
    done

    return $SUCCESS
}


# confirm user inputted yYnN
confirm_title()
{
    header="$1"
    ask="$2"

    while true
    do
        title "$header"
        woutput "$ask"
        read -r input
        case $input in
            y|Y|yes|YES|Yes) return $TRUE ;;
            n|N|no|NO|No) return $FALSE ;;
            *) err 'Incorrect option! Try again...' ; sleep 2 ; clear ; continue ;;
        esac
    done

    return $SUCCESS
}


# print menu title
title()
{
    banner
    printf "${BLUE}>> %s${NC}\n\n\n" "${@}"

    return "${SUCCESS}"
}


# check for environment issues
check_env()
{
    if [ -f '/var/lib/pacman/db.lck' ]
    then
        warn 'Pacman locked - Removing /var/lib/pacman/db.lck'
        rm -f /var/lib/pacman/db.lck
    fi

    return $SUCCESS
}


## check user id
#check_uid()
#{
#    if [ "$(id -u)" != '0' ]
#    then
#        err 'You must be root to run overdeep-installer!'
#        exit $FAILURE
#    fi
#
#    return $SUCCESS
#}


# check boot mode
check_boot_mode()
{
    efivars=$(ls /sys/firmware/efi/efivars > /dev/null 2>&1; echo $?)
    if [ "$efivars" -eq "0" ]
    then
        BOOT_MODE="uefi"
    else
        BOOT_MODE="legacy"
    fi

    return $SUCCESS
}


# check the current running init system
check_init_system()
{
    if [ "$(stat /sbin/init | grep -o systemd) > /dev/null 2>&1" != '' ]
    then
        CUR_INIT_SYSTEM='systemd'
    elif [ "$(stat /sbin/init | grep -o openrc) > /dev/null 2>&1" != '' ]
    then
        CUR_INIT_SYSTEM='openrc'
    elif [ "$(stat /sbin/init | grep -o runit) > /dev/null 2>&1" != '' ]
    then
        CUR_INIT_SYSTEM='runit'
    else
        CUR_INIT_SYSTEM='sysvinit'
    fi

    return $SUCCESS
}


# check the current running system name
#check_system()
#{
#    if [ "$(cat /etc/os-release | grep -w 'ID' | awk -F '=' '{print $2}')" = 'arch' ]
#    then
#}


# check for internet connection
check_internet()
{
    title 'Check Internet'
    woutput '[+] Checking for Internet connection...'
    printf "\n\n"

    if ! curl -s http://www.yahoo.com/ > /dev/null
    then
        warn 'No internet connection detected!'
        if confirm '[?] Continue on offline mode [y/n]: '
        then
            warn 'Continuing on offline mode...'
        else
            err 'Quitting...'
            sleep_clear 0
            exit $FAILURE
        fi
    else
        okay "Internet Connection Working!\nContinuing..."
        return $SUCCESS
    fi
}


# check if new version available. perform self-update and exit
self_updater()
{
    title 'Self Updater'
    woutput '[+] Checking for a new version of myself...'
    printf "\n\n"

    repo="$(timeout -s SIGTERM 20 curl https://raw.githubusercontent.com/WhitedonSAP/overdeep-tools/main/version.txt 2> /dev/null)"
    this="$(echo $VERSION)"

    if [[ "$repo" != "$this" ]]
    then
        warn 'A new version is available! Going update myself...'
        ## remove old directory if exist
        #if [[ -d "../$BASEDIR/overdeep-tools-*.old" ]]
        #then
        #    rm -rf "../$BASEDIR/overdeep-tools-*.old"
        #fi
        ## move the files to create .old directory
        #cd ..
        #mkdir "overdeep-tools-$VERSION.old"
        #mv overdeep-tools/* "overdeep-tools-$VERSION.old/"
        # restore options and download the new files to replace
        #cd overdeep-tools
        cd ..
        # remove old version
        rm -rf overdeep-tools
        # download new version
        git clone https://github.com/WhitedonSAP/overdeep-tools.git
        if [ $? = 0 ]
        then
            okay 'Updated successfully. Please restart the installer now'
        else
            err 'There was a problem updating! Try again later...'
            exit $FAILURE
        fi
        # apply permission of execution
        chmod +x overdeep-tools/overdeep-installer.sh
        exit $SUCCESS
    else
        okay 'You already have the latest version of the Overdeep-Installer! Continuing...'
    fi

    sleep_clear 0

    return $SUCCESS
}


# check firstrun
check_firstrun()
{
    if [ -f .firstrun ]
    then
        main_menu
    else
        touch .firstrun
        welcome
    fi

    return $SUCCESS
}


# welcome msg
welcome()
{
    title 'Welcome to the Overdeep-Installer!'
    read -p "Press 'Enter' to continue"

    return $SUCCESS
}


# main menu
main_menu()
{
    while true
    do
        title 'Main Menu'
        woutput '[+] Available options:'
        printf "\n
      1. Select Distros
      2. Internet Settings
      3.
      4.
      5.
      6.
      7.
      8.
      9.
      10.
      11. Self Updater
      12. Quit\n\n"
        woutput '[?] Make a choice: '
        read -r main_menu_option
        if [ "$main_menu_option" = 1 ]
        then
            sleep_clear 0
            select_distros
        elif [ "$main_menu_option" = 2 ]
        then
            sleep_clear 0
        #if [ "$main_menu_option" = 3 ]
        #then
        else
            err 'Incorrect option! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# select the distro to install
select_distros()
{
    while true
    do
        title 'Select Distros'
        woutput '[+] Choose an available distro:'
        printf "\n
      1. Overdeep OS
      2. Archlinux
      3. Blackarch
      4. Gentoo
      5. Funtoo\n\n"
        woutput '[?] Make a choice: '
        read -r INSTALL_MODE
        if [ "$INSTALL_MODE" = 1 ] || \
            [ "$INSTALL_MODE" = 2 ] || \
            [ "$INSTALL_MODE" = 3 ] || \
            [ "$INSTALL_MODE" = 4 ] || \
            [ "$INSTALL_MODE" = 5 ]
        then
            if [ "$INSTALL_MODE" = 1 ]
            then
                DISTRO_NAME='Overdeep OS'
            elif [ "$INSTALL_MODE" = 2 ]
            then
                DISTRO_NAME='Archlinux'
            elif [ "$INSTALL_MODE" = 3 ]
            then
                DISTRO_NAME='Blackarch'
            elif [ "$INSTALL_MODE" = 4 ]
            then
                DISTRO_NAME='Gentoo'
            elif [ "$INSTALL_MODE" = 5 ]
            then
                DISTRO_NAME='Funtoo'
            fi
            break
        else
            err 'Incorrect option! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# ask for output mode
ask_output_mode()
{
    while true
    do
        title 'Environment > Output Mode'
        woutput '[+] Available output modes:'
        printf "\n
      1. Quiet (default)
      2. Verbose (output of system commands: mkfs, etc.)\n\n"
        woutput "[?] Make a choice: "
        read -r output_mode
        if [ "$output_mode" = '' ] || [ "$output_mode" = 1 ]
        then
            VERBOSE='/dev/null'
            break
        elif [ "$output_mode" = 2 ]
        then
            VERBOSE='/dev/stdout'
            break
        else
            err 'Incorrect option! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# ask for locale to use
ask_locale()
{
    while true
    do
        title 'Environment > Locale Setup'
        woutput '[+] Available locale options:'
        printf "\n
      1. Set a locale
      2. List available locales\n\n"
        woutput "[?] Make a choice: "
        read -r locale_opt
        if [ "$locale_opt" = 1 ]
        then
            break
        elif [ "$locale_opt" = 2 ]
        then
            less locales.txt
            clear
            continue
        else
            err 'Incorrect option! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# set locale to use
set_locale()
{
    while true
    do
        title 'Environment > Locale Setup'
        woutput '[?] Set locale [default: en_US.UTF-8]: '
        read -r LOCALE
        # default locale
        if [ -z "$LOCALE" ]
        then
            warn "Setting $DEF_LOCALE as default locale"
            LOCALE=$DEF_LOCALE
            break
        elif [ "$LOCALE" = "$(cat locales.txt | grep -w $LOCALE)" ]
        then
            warn "Setting $LOCALE as default locale and $DEF_LOCALE as fallback"
            break
        else
            err 'The locale is incorrect! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# ask to set locale for the current system (systemd only for now)
set_current_locale()
{
    if confirm_title 'Environment > Current Locale Setup' \
    '[?] Set the locale for the current running system [y/n]: '
    then
        warn "Setting $LOCALE for the current system"
        localectl set-locale "LANG=$LOCALE"
        check $? 'setting locale'
    else
        warn 'Keeping the current locale'
        sleep_clear 0
    fi

    return $SUCCESS
}


# ask for keymap to use
ask_keymap()
{
    while true
    do
        title 'Environment > Keymap Setup'
        woutput '[+] Available keymap options:'
        printf "\n
      1. Set a keymap
      2. List available keymaps\n\n"
        woutput '[?] Make a choice: '
        read -r keymap_opt
        if [ "$keymap_opt" = 1 ]
        then
            break
        elif [ "$keymap_opt" = 2 ]
        then
            less keymaps.txt
            clear
            continue
        else
            err 'Incorrect option! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# set keymap to use
set_keymap()
{
    while true
    do
        title 'Environment > Keymap Setup'
        woutput '[?] Set keymap [default: us]: '
        read -r KEYMAP
        # default keymap
        if [ -z "$KEYMAP" ]
        then
            warn "Setting $DEF_KEYMAP as default keymap"
            KEYMAP=$DEF_KEYMAP
            break
        elif [ "$KEYMAP" = "$(cat keymaps.txt | grep -w $KEYMAP)" ]
        then
            warn "Setting $KEYMAP as default keymap"
            break
        else
            err 'The keymap is incorrect! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}


# ask to set keymap for the current system (systemd only for now)
set_current_keymap()
{
    if confirm_title 'Environment > Current Keymap Setup' \
    '[?] Set the keymap for the current running system [y/n]: '
    then
        warn "Setting $KEYMAP for the current system"
        localectl set-keymap --no-convert "$KEYMAP"
        check $? 'setting keymap'
    else
        warn 'Keeping the current keymap'
        sleep_clear 0
    fi

    return $SUCCESS
}


# ask user for hostname
ask_hostname()
{
    while true
    do
        title 'Network Setup > Hostname'
        woutput '[?] Set your hostname: '
        read -r HOST_NAME
        printf "\n"

        if [ "$HOST_NAME" != '' ]
        then
            warn "Setting $HOST_NAME as hostname"
            break
        elif [ "$HOST_NAME" = '' ]
        then
            err 'No hostname set! Try again...'
            sleep_clear 0
            continue
        fi
    done

    return $SUCCESS
}

# get available network interfaces
get_net_ifs()
{
    NET_IFS="$(ip -o link show | awk -F': ' '{print $2}' |grep -v 'lo')"

    return $SUCCESS
}


# ask user for network interface
ask_net_if()
{
    while true
    do
        title 'Network Setup > Network Interface'
        woutput '[+] Available network interfaces:'
        printf "\n\n"
        for i in $NET_IFS
        do
            echo "    > $i"
        done
        echo
        woutput '[?] Please choose a network interface: '
        read -r NET_IF
        if echo "$NET_IFS" | grep "\<$NET_IF\>" > /dev/null
        then
            clear
            break
        fi
        clear
    done

    return $SUCCESS
}


# ask for networking configuration mode
ask_net_conf_mode()
{
    while [ "$NET_CONF_MODE" != "$NET_CONF_AUTO" ] && \
          [ "$NET_CONF_MODE" != "$NET_CONF_WLAN" ] && \
          [ "$NET_CONF_MODE" != "$NET_CONF_MANUAL" ] && \
          [ "$NET_CONF_MODE" != "$NET_CONF_SKIP" ]
    do
        title 'Network Setup > Network Interface'
        woutput '[+] Network interface configuration:'
        printf "\n
      1. Auto DHCP (use this for auto connect via dhcp on selected interface)
      2. WiFi WPA Setup (use if you need to connect to a wlan before)
      3. Manual (use this if you are 1337)
      4. Skip (use this if you are already connected)\n\n"
        woutput "[?] Please choose a mode: "
        read -r NET_CONF_MODE
        clear
    done

    return $SUCCESS
}


# ask for network addresses
ask_net_addr()
{
    while [ "$HOST_IPV4" = "" ] || \
          [ "$GATEWAY" = "" ] || [ "$SUBNETMASK" = "" ] || \
          [ "$BROADCAST" = "" ] || [ "$NAMESERVER" = "" ]
    do
        title 'Network Setup > Network Configuration (manual)'
        woutput "[+] Configuring network interface $NET_IF via USER: "
        printf "\n
      > Host ipv4
      > Gateway ipv4
      > Subnetmask
      > Broadcast
      > Nameserver\n\n"
        woutput '[?] Host IPv4: '
        read -r HOST_IPV4
        woutput '[?] Gateway IPv4: '
        read -r GATEWAY
        woutput '[?] Subnetmask: '
        read -r SUBNETMASK
        woutput '[?] Broadcast: '
        read -r BROADCAST
        woutput '[?] Nameserver: '
        read -r NAMESERVER
        clear
    done

    return $SUCCESS
}


# manual network interface configuration
net_conf_manual()
{
    title 'Network Setup > Network Configuration (manual)'
    woutput "[+] Configuring network interface '$NET_IF' manually: "
    printf "\n\n"

    ip addr flush dev "$NET_IF"
    ip link set "$NET_IF" up
    ip addr add "$HOST_IPV4/$SUBNETMASK" broadcast "$BROADCAST" dev "$NET_IF"
    ip route add default via "$GATEWAY"
    echo "nameserver $NAMESERVER" > /etc/resolv.conf

    return $SUCCESS
}


# auto (dhcp) network interface configuration
net_conf_auto()
{
    opts='-h noleak -i noleak -v ,noleak -I noleak -t 10'

    title 'Network Setup > Network Configuration (auto)'
    woutput "[+] Configuring network interface '$NET_IF' via DHCP: "
    printf "\n\n"

    dhcpcd "$opts" -i "$NET_IF" > $VERBOSE 2>&1

    sleep 10

    return $SUCCESS
}


# ask for wlan data (ssid, wpa passphrase, etc.)
ask_wlan_data()
{
    while [ "$WLAN_SSID" = "" ] || [ "$WLAN_PASSPHRASE" = "" ]
    do
        title 'Network Setup > Network Configuration (WiFi)'
        woutput "[+] Configuring network interface $NET_IF via W-LAN + DHCP: "
        printf "\n
      > W-LAN SSID
      > WPA Passphrase (will not echo)\n\n"
        woutput "[?] W-LAN SSID: "
        read -r WLAN_SSID
        woutput "[?] WPA Passphrase: "
        read -rs WLAN_PASSPHRASE
        clear
    done

    return $SUCCESS
}


# wifi and auto dhcp network interface configuration
net_conf_wlan()
{
    wpasup="$(mktemp)"
    dhcp_opts='-h noleak -i noleak -v ,noleak -I noleak -t 10'

    title 'Network Setup > Network Configuration (WiFi)'
    woutput "[+] Configuring network interface $NET_IF via W-LAN + DHCP: "
    printf "\n\n"

    wpa_passphrase "$WLAN_SSID" "$WLAN_PASSPHRASE" > "$wpasup"
    wpa_supplicant -B -c "$wpasup" -i "$NET_IF" > $VERBOSE 2>&1

    warn 'We need to wait a bit for wpa_supplicant and dhcpcd'

    sleep 10

    dhcpcd "$dhcp_opts" -i "$NET_IF" > $VERBOSE 2>&1

    sleep 10

    return $SUCCESS
}


# ask user for dualboot install
ask_dualboot()
{
    while [ "$DUALBOOT" = '' ]
    do
        if confirm_title 'Hard Drive Setup > DualBoot' \
        '[?] Install Overdeep OS with Windows/Other OS [y/n]: '
        then
            DUALBOOT=$TRUE
        else
            DUALBOOT=$FALSE
        fi
    done

    return $SUCCESS
}


# ask user for luks encrypted partition
ask_luks()
{
    while [ "$LUKS" = '' ]
    do
        if confirm_title 'Hard Drive Setup > Crypto' \
        '[?] Full encrypted root [y/n]: '
        then
            LUKS=$TRUE
        else
            LUKS=$FALSE
            echo
            warn 'The root partition will NOT be encrypted'
        fi
    done

    return $SUCCESS
}


# get available hard disks
get_hd_devs()
{
    HD_DEVS="$(lsblk | grep disk | awk '{print $1}')"

    return $SUCCESS
}


# ask user for device to format and setup
ask_hd_dev()
{
    while true
    do
        title 'Hard Drive Setup > Device'
        woutput '[+] Available hard drives for installation:'
        printf "\n\n"

        for i in $HD_DEVS
        do
            echo "    > ${i}"
        done
        echo

        woutput '[?] Please choose a device: '
        read -r HD_DEV
        if echo "$HD_DEVS" | grep "\<$HD_DEV\>" > /dev/null
        then
            HD_DEV="/dev/$HD_DEV"
            clear
            break
        fi
        clear
    done

    return $SUCCESS
}

# get available partitions on hard drive
get_partitions()
{
    PARTITIONS=$(fdisk -l "${HD_DEV}" -o device,size,type | \
    grep "${HD_DEV}[[:alnum:]]" |awk '{print $1;}')

    return $SUCCESS
}


# ask user to create partitions using cfdisk
ask_cfdisk()
{
    if confirm_title 'Hard Drive Setup > Partitions' \
    '[?] Create partitions with cfdisk (root and boot, optional swap) [y/n]: '
    then
        woutput '[+] Cfdisk Default scheme:'
        if [ "$BOOT_MODE" = 'uefi' ]
        then
            printf "\n\n
          Bios UEFI detected!\n\n
          EFI partition (if it doesn't exist) ------> EF00 256M
          Swap partition ---------------------------> 8200 (Your ram memory/2)
          System Root partition --------------------> 8300 +5G\n\n"
        elif [ "$BOOT_MODE" = 'legacy' ]
        then
            printf "\n\n
          Bios Legacy detected!\n\n
          For MBR scheme:\n
          Bios boot partition ----------------------> EF02 1M
          System Boot partition --------------------> 8300 256M
          Swap partition ---------------------------> 8200 (Your ram memory/2)
          System Root partition --------------------> 8300 +5G
          For GPT scheme:\n
          System Boot partition --------------------> 8300 256M
          Swap partition ---------------------------> 8200 (Your ram memory/2)
          System Root partition --------------------> 8300 +5G\n\n"
        fi
        read -p "Type 'Enter' to continue..."
        clear
        zero_part
    else
        echo
        warn 'No partitions chosed? Make sure you have them already configured.'
        get_partitions
    fi

    return $SUCCESS
}


# zero out partition if needed/chosen
zero_part()
{
    local zeroed_part=0;
    if confirm_title 'Hard Drive Setup' \
    '[?] Start with an in-memory zeroed partition table [y/n]: '
    zeroed_part=1;
    then
        cfdisk -z "$HD_DEV"
        sync
    else
        cfdisk "$HD_DEV"
        sync
    fi
    get_partitions
    if [ ${#PARTITIONS[@]} -eq 0 ] && [ $zeroed_part -eq 1 ]
    then
        err 'You have not created partitions on your disk, \
        make sure to write your changes before quiting cfdisk. Trying again...'
        zero_part
    fi
    if [ "$BOOT_MODE" = 'uefi' ] && ! fdisk -l "$HD_DEV" -o type | grep -i 'EFI' > /dev/null 2>&1
    then
        err 'You are booting in UEFI mode but not EFI partition was created, \
        make sure you select the "EFI System" type for your EFI partition.'
        zero_part
    fi

    return $SUCCESS
}


# get partition label
get_partition_label()
{
    PART_LABEL="$(fdisk -l "$HD_DEV" |grep "Disklabel" | awk '{print $3;}')"

    return $SUCCESS
}


# get partitions
ask_partitions()
{
    title 'Hard Drive Setup > Filesystems'
    woutput '[+] Created partitions:'
    printf "\n\n"

    fdisk -l "${HD_DEV}" -o device,size,type |grep "${HD_DEV}[[:alnum:]]"

    echo

    # boot partition
    if [ "$BOOT_MODE" = 'legacy' ]
    then
        while [ -z "$BOOT_PART" ]
        do
            woutput "[?] Boot partition (${HD_DEV}X): "
            read -r BOOT_PART
            until [[ "$PARTITIONS" =~ $BOOT_PART ]]
            do
                woutput "[?] Your partition $BOOT_PART is not in the partitions list.\n"
                woutput "[?] Boot partition (${HD_DEV}X): "
                read -r BOOT_PART
            done
        done
        while true
        do
            woutput '[?] Choose a filesystem (ext2/ext4/btrfs) to use in your boot partition (Default - ext4): '
            read -r $BOOT_FS_TYPE
            if [ -z "$BOOT_FS_TYPE" ]
            then
                BOOT_FS_TYPE='ext4'
                break
            fi
            case $BOOT_FS_TYPE in
                ext2|ext4|btrfs)
                warn "Default filesystem for BOOT set to $BOOT_FS_TYPE"
                break
                ;;
                *)
                err 'Wrong filesystem type. Try again...'
                continue
                ;;
            esac
        done
    fi

    # root partition
    while [ -z "$ROOT_PART" ]
    do
        woutput "[?] Root partition (${HD_DEV}X): "
        read -r ROOT_PART
        until [[ "$PARTITIONS" =~ $ROOT_PART ]]
        do
            woutput "[?] Your partition $ROOT_PART is not in the partitions list.\n"
            woutput "[?] Root partition (${HD_DEV}X): "
            read -r ROOT_PART
        done
    done
    while true
    do
        woutput '[?] Choose a filesystem (ext4/xfs/jfs/f2fs/btrfs) to use in your root partition (Default - ext4): '
        read -r ROOT_FS_TYPE
        if [ -z "$ROOT_FS_TYPE" ]
        then
            ROOT_FS_TYPE="ext4"
            break
        fi
        case $ROOT_FS_TYPE in
            ext4|xfs|jfs|f2fs|btrfs)
            warn "Default filesystem for ROOT set to $ROOT_FS_TYPE"
            break
            ;;
            *)
            err 'Wrong filesystem type. Try again...'
            continue
            ;;
        esac
    done

    # swap partition
    woutput "[?] Swap partition (${HD_DEV}X - empty for none): "
    read -r SWAP_PART
    if [ -n "$SWAP_PART" ]
    then
        until [[ "$PARTITIONS" =~ $SWAP_PART ]]
        do
            woutput "[?] Your partition $SWAP_PART is not in the partitions list.\n"
            woutput "[?] Swap partition (${HD_DEV}X): "
            read -r SWAP_PART
        done
    elif [ "$SWAP_PART" = '' ]
    then
        SWAP_PART='none'
    fi

    clear

    return $SUCCESS
}


# create subvols on btrfs
ask_btrfs_subvol()
{
    if confirm_title 'Hard Drive Setup > Btrfs Subvols' '[?] Create subvols to have system snapshots? [y/n]: '
    then
        return $SUCCESS
    else
        BTRFS_SUBVOL=$FALSE
        echo
        warn 'No creatting subvols on btrfs filesystem...'
    fi

    return $SUCCESS
}


# ask user and get confirmation for formatting
confirm_all()
{
    while true
    do
        title 'Hard Drive Setup > Confirm Settings'
        woutput '[+] Check that all information is correct:'
        printf "\n
      Hostname: $HOST_NAME
      Language: $LOCALE
      Keymap: $KEYMAP\n"
        if [ $DUALBOOT = $TRUE ]
        then
            printf "DualBoot: Yes"
        else
            printf "DualBoot: No"
        fi
        if [ $LUKS = $TRUE ]
        then
            printf "Luks: Yes"
        else
            printf "Luks: No"
        fi
        echo
        if [ "$BOOT_MODE" = 'uefi' ] && [ $BTRFS_SUBVOL = $TRUE ]
        then
            EFI_PART="$(fdisk -l "$HD_DEV" | grep -i 'EFI' | awk '{print $1}')"
            woutput '[+] Partition table:'
            printf "\n
          > /boot/efi  :  %s (efi)
          > /          :  %s (%s) (subvols: @ and @home)
          > swap       :  %s (swap)\n"
                    "$EFI_PART" \
                    "$ROOT_PART" "$ROOT_FS_TYPE" \
                    "$SWAP_PART"
        elif [ "$BOOT_MODE" = 'legacy' ] && [ $BTRFS_SUBVOL = $TRUE ]
        then
            woutput '[+] Partition table:'
            printf "\n
          > /boot  :  %s (%s)
          > /      :  %s (%s) (subvols: @ and @home)
          > swap   :  %s (swap)\n"
                "$BOOT_PART" "$BOOT_FS_TYPE" \
                "$ROOT_PART" "$ROOT_FS_TYPE" \
                "$SWAP_PART"
        elif [ "$BOOT_MODE" = 'uefi' ] && [ $BTRFS_SUBVOL = $FALSE ]
        then
            EFI_PART="$(fdisk -l "$HD_DEV" | grep -i 'EFI' | awk '{print $1}')"
            woutput '[+] Partition table:'
            printf "\n
          > /boot/efi  :  %s (efi)
          > /          :  %s (%s)
          > swap       :  %s (swap)\n"
                    "$EFI_PART" \
                    "$ROOT_PART" "$ROOT_FS_TYPE" \
                    "$SWAP_PART"
        elif [ "$BOOT_MODE" = 'legacy' ] && [ $BTRFS_SUBVOL = $FALSE ]
        then
            woutput '[+] Partition table:'
            printf "\n
          > /boot  :  %s (%s)
          > /      :  %s (%s)
          > swap   :  %s (swap)\n"
                "$BOOT_PART" "$BOOT_FS_TYPE" \
                "$ROOT_PART" "$ROOT_FS_TYPE" \
                "$SWAP_PART"
        fi
        echo
        if confirm '[?] All Ok? [y/n]: '
        then
            if confirm '[?] Are you sure you want to continue? It will not be possible to come back here again afterwards! [y/n]: '
            then
                break
                return $SUCCESS
            else
                warn 'Verify the settings again...'
                sleep_clear 0
                continue
            fi
        else
            if confirm '[?] Setup the hard drive again [y/n]: '
            then
                clear
                if [ "$BOOT_MODE" = 'uefi' ]
                then
                    EFI_PART=''
                elif [ "$BOOT_MODE" = 'legacy' ]
                then
                    BOOT_PART=''
                    BOOT_FS_TYPE=''
                fi
                ROOT_PART=''
                ROOT_FS_TYPE=''
                SWAP_PART=''
                BTRFS_SUBVOL=$FALSE
                sleep_clear 0
                ask_partitions
            else
                err 'Hard Drive Setup aborted. Cancelling...'
                warn 'Run this script anytime for try again...'
                exit $FAILURE
            fi
        fi
    done

    return $SUCCESS
}


# create LUKS encrypted partition
make_luks_partition()
{
    part="$1"

    title 'Hard Drive Setup > Partition Creation (crypto)'

    woutput '[+] Creating LUKS partition'
    printf "\n\n"

    cryptsetup -q -y -v luksFormat "$part" > $VERBOSE 2>&1 ||
        { err 'Could not LUKS format, trying again.'; make_luks_partition "$@"; }

    return $SUCCESS
}


# open LUKS partition
open_luks_partition()
{
    part="$1"
    name="$2"

    title 'Hard Drive Setup > Partition Creation (crypto)'

    woutput '[+] Opening LUKS partition'
    printf "\n\n"
    cryptsetup open "$part" "$name" > $VERBOSE 2>&1 ||
        { err 'Could not open LUKS device, please try again and make sure that your password is correct.'; open_luks_partition "$@"; }

    return $SUCCESS
}


# make/set the efi partition
make_efi_partition()
{
    if [ $DUALBOOT = $TRUE ]
    then
        return $SUCCESS
    fi

    title 'Hard Drive Setup > Partition Creation (efi)'

    woutput '[+] Creating EFI partition'
    printf "\n\n"

    mkfs.fat -c -n "EFI" -F 32 "$EFI_PART" > $VERBOSE 2>&1 ||
        { err 'Could not create filesystem'; exit $FAILURE; }

    return $SUCCESS
}


# make and format boot partition
make_boot_partition()
{
    title 'Hard Drive Setup > Partition Creation (boot)'

    woutput '[+] Creating BOOT partition'
    printf "\n\n"

    if [ "$BOOT_FS_TYPE" = 'ext2' ] || [ "$BOOT_FS_TYPE" = 'ext4' ]
    then
        mkfs.$BOOT_FS_TYPE -L "BOOT" -F "$BOOT_PART" > $VERBOSE 2>&1 ||
            { err 'Could not create filesystem'; exit $FAILURE; }
    elif [ "$BOOT_FS_TYPE" = 'btrfs' ]
    then
        mkfs.$BOOT_FS_TYPE -L "BOOT" -f "$BOOT_PART" > $VERBOSE 2>&1 ||
            { err 'Could not create filesystem'; exit $FAILURE; }
    fi

    return $SUCCESS
}


# make and format root partition
make_root_partition()
{
    if [ $LUKS = $TRUE ]
    then
        make_luks_partition "$ROOT_PART"
        sleep_clear 1
        open_luks_partition "$ROOT_PART" "$CRYPT_ROOT"
        sleep_clear 1
        title 'Hard Drive Setup > Partition Creation (root crypto)'
        woutput '[+] Creating encrypted ROOT partition'
        printf "\n\n"
        if [ "$ROOT_FS_TYPE" = 'ext4' ]
        then
            mkfs.$ROOT_FS_TYPE -c -L '"'$DISTRO_NAME'"' -F "/dev/mapper/$CRYPT_ROOT" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'xfs' ]
        then
            mkfs.$ROOT_FS_TYPE -L '"'$DISTRO_NAME'"' -f "/dev/mapper/$CRYPT_ROOT" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'jfs' ]
        then
            mkfs.$ROOT_FS_TYPE -c -L '"'$DISTRO_NAME'"' "/dev/mapper/$CRYPT_ROOT" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'f2fs' ]
        then
            mkfs.$ROOT_FS_TYPE -l '"'$DISTRO_NAME'"' -f "/dev/mapper/$CRYPT_ROOT" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'btrfs' ]
        then
            mkfs.$ROOT_FS_TYPE -L '"'$DISTRO_NAME'"' -f "/dev/mapper/$CRYPT_ROOT" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        fi
    else
        title 'Hard Drive Setup > Partition Creation (root)'
        woutput '[+] Creating ROOT partition'
        printf "\n\n"
        if [ "$ROOT_FS_TYPE" = 'ext4' ]
        then
            mkfs.$ROOT_FS_TYPE -c -L '"'$DISTRO_NAME'"' -F "$ROOT_PART" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'xfs' ]
        then
            mkfs.$ROOT_FS_TYPE -L '"'$DISTRO_NAME'"' -f "$ROOT_PART" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'jfs' ]
        then
            mkfs.$ROOT_FS_TYPE -c -L '"'$DISTRO_NAME'"' "$ROOT_PART" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'f2fs' ]
        then
            mkfs.$ROOT_FS_TYPE -l '"'$DISTRO_NAME'"' -f "$ROOT_PART" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        elif [ "$ROOT_FS_TYPE" = 'btrfs' ]
        then
            mkfs.$ROOT_FS_TYPE -L '"'$DISTRO_NAME'"' -f "$ROOT_PART" > $VERBOSE 2>&1 ||
                { err 'Could not create filesystem'; exit $FAILURE; }
        fi
    fi

    return $SUCCESS
}


# make and format partitions
make_partitions()
{
    if [ "$BOOT_MODE" = 'uefi' ]
    then
        make_efi_partition
        sleep_clear 1
    fi

    if [ "$BOOT_MODE" = 'legacy' ]
    then
        make_boot_partition
        sleep_clear 1
    fi

    make_root_partition
    sleep_clear 1

    if [ "$SWAP_PART" != "none" ]
    then
        make_swap_partition
        sleep_clear 1
    fi

    return $SUCCESS
}


# create swap partition
make_swap_partition()
{
    title 'Hard Drive Setup > Partition Creation (swap)'

    woutput '[+] Creating SWAP partition'
    printf "\n\n"
    if [[ "$(df | grep -o $SWAP_PART)" != '' ]]
    then
        swapoff $SWAP_PART
    fi
    mkswap -c -L "SWAP" "$SWAP_PART" > $VERBOSE 2>&1 ||
        { err 'Could not create filesystem'; exit $FAILURE; }

    return $SUCCESS
}


# mount filesystems
mount_filesystems()
{
    title 'Hard Drive Setup > Mount'

    woutput '[+] Mounting filesystems'
    printf "\n\n"

    # Check
    if [[ $(find $CHROOT > /dev/null 2>&1) != "$CHROOT" ]]
    then
        warn "Directory $CHROOT not detected! Creating it..."
        mkdir -p $CHROOT
    else
        warn "Directory $CHROOT detected! Continuing..."
    fi

    echo

    # ROOT
    if [ $LUKS = $TRUE ]
    then
        if ! mount "/dev/mapper/$CRYPT_ROOT" $CHROOT
        then
            err "Error mounting root filesystem, leaving."
            exit $FAILURE
        fi
    elif [ $LUKS = $FALSE ]
    then
        if ! mount "$ROOT_PART" $CHROOT
        then
            err "Error mounting root filesystem, leaving."
            exit $FAILURE
        fi
    fi

    # Btrfs subvols
    if [ "$ROOT_FS_TYPE" = 'btrfs' ] && [ $BTRFS_SUBVOL = $TRUE ]
    then
        # create subvols
        warn 'Creating subvols @ and @home on rootfs...'
        btrfs subvol create "$CHROOT/@"
        btrfs subvol create "$CHROOT/@home"
        # unmounting
        umount -lRf $CHROOT > /dev/null 2>&1; \
        umount -lRf "$HD_DEV"{1..128} > /dev/null 2>&1 # gpt max - 128
        # mounting subvols
        if [ $LUKS = $TRUE ]
        then
            if ! mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@ \
            "/dev/mapper/$CRYPT_ROOT" $CHROOT
            then
                err "Error mounting luks btrfs subvol @, leaving."
                exit $FAILURE
            fi
            mkdir -p "$CHROOT/home"
            if ! mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@home \
            "/dev/mapper/$CRYPT_ROOT" "$CHROOT/home"
            then
                err "Error mounting luks btrfs subvol @home, leaving."
                exit $FAILURE
            fi
        else
            if ! mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@ \
            "$ROOT_PART" $CHROOT
            then
                err "Error mounting btrfs subvol @, leaving."
                exit $FAILURE
            fi
            mkdir -p "$CHROOT/home"
            if ! mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@home \
            "$ROOT_PART" "$CHROOT/home"
            then
                err "Error mounting btrfs subvol @home, leaving."
                exit $FAILURE
            fi
        fi
    fi

    # EFI (if BOOT_MODE='uefi')
    if [ "$BOOT_MODE" = 'uefi' ]
    then
        mkdir -p "$CHROOT/boot/efi"
        if ! mount "$EFI_PART" "$CHROOT/boot/efi"
        then
            err "Error mounting efi partition, leaving."
            exit $FAILURE
        fi
    fi

    # BOOT (if BOOT_MODE='legacy')
    if [ "$BOOT_MODE" = 'legacy' ]
    then
        mkdir -p "$CHROOT/boot"
        if ! mount -t btrfs -o defaults,noatime,compress=zstd "$BOOT_PART" "$CHROOT/boot"
        then
            err "Error mounting boot partition, leaving."
            exit $FAILURE
        fi
    fi

    # SWAP
    if [ "$SWAP_PART" != "none" ]
    then
        swapon "$SWAP_PART" > $VERBOSE 2>&1
    fi

    return $SUCCESS
}


# unmount filesystems
umount_filesystems()
{
    routine="$1"

    if [ "$routine" = 'harddrive' ]
    then
        title 'Hard Drive Setup > Unmount'

        woutput '[+] Unmounting filesystems'
        printf "\n\n"

        umount -Rf $CHROOT > /dev/null 2>&1; \
        umount -Rf "$HD_DEV"{1..128} > /dev/null 2>&1 # gpt max - 128
    else
        title 'Game Over'

        woutput '[+] Unmounting filesystems'
        printf "\n\n"

        umount -Rf $CHROOT > /dev/null 2>&1
        cryptsetup luksClose "$CRYPT_ROOT" > /dev/null 2>&1
        swapoff "$SWAP_PART" > /dev/null 2>&1
    fi

    return $SUCCESS
}


# check for necessary space
check_space()
{
    if [ $LUKS -eq $TRUE ]
    then
        avail_space=$(df -m | grep "/dev/mapper/$CRYPT_ROOT" | awk '{print $4}')
    else
        avail_space=$(df -m | grep "$ROOT_PART" | awk '{print $4}')
    fi

    if [ "$avail_space" -le 5000 ]
    then
        warn "$DISTRO_NAME requires at least 5 GB of free space to run perfectly!"
    fi

    return $SUCCESS
}


# setup /etc/resolv.conf
setup_resolvconf()
{
    title 'Base System Setup > resolv.conf'

    woutput '[+] Setting up /etc/resolv.conf'
    printf "\n\n"

    cp --dereference /etc/resolv.conf "$CHROOT/etc/"

    return $SUCCESS
}


# setup fstab
setup_fstab()
{
    title 'Base System Setup > Fstab'

    woutput '[+] Setting up /etc/fstab'
    printf "\n\n"

    echo -e "## File generated automatically by genfstab\n" > "$CHROOT/etc/fstab"

    if [ "$PART_LABEL" = "gpt" ]
    then
        genfstab -U $CHROOT >> "$CHROOT/etc/fstab"
    elif [ "$PART_LABEL" = "dos" ]
    then
        genfstab -L $CHROOT >> "$CHROOT/etc/fstab"
    fi

    sed -i 's/relatime/noatime/g' "$CHROOT/etc/fstab"

    # remove subvolid for work with snapshots (btrfs)
    if [ "$ROOT_FS_TYPE" = 'btrfs' ]
    then
        sed -i 's/,subvolid=\<[0-9]*\>//g' "$CHROOT/etc/fstab"
    fi

    return $SUCCESS
}


# setup locale
setup_locale()
{
    title 'Base System Setup > Locale'
    woutput "[+] Setting up $LOCALE locale"
    printf "\n\n"

    echo -e "## File generated automatically by overdeep-installer\nen_US.UTF-8 UTF-8" > "$CHROOT/etc/locale.gen"
    echo ''"$LOCALE"' UTF-8' >> "$CHROOT/etc/locale.gen"
    chroot $CHROOT locale-gen > $VERBOSE 2>&1
    if [ "$INIT_SYSTEM" = 'openrc' ]
    then
        echo -e 'LANG='"$LOCALE"'\nLC_COLLATE='"C.UTF-8"'' > "$CHROOT/etc/env.d/02locale"
    elif [ "$INIT_SYSTEM" = 'systemd' ]
    then
        echo 'LANG='"$LOCALE"'' > "$CHROOT/etc/locale.conf"
    fi

    return $SUCCESS
}


# setup keymap
setup_keymap()
{
    title 'Base System Setup > Keymap'
    woutput "[+] Setting up $KEYMAP keymap"
    printf "\n\n"

    if [ "$INIT_SYSTEM" = 'openrc' ]
    then
        sed "$CHROOT/etc/conf.d/keymaps"
    fi
}


# setup timezone
setup_time()
{
    time=''

    if confirm_title 'Base System Setup > Timezone' '[?] Default: UTC. Choose other timezone [y/n]: '
    then
        for t in $(chroot $CHROOT timedatectl list-timezones)
        do
            echo "    > $time"
        done

        woutput "\n[?] What is your (Zone/SubZone): "
        read -r timezone
        chroot $CHROOT ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime \
            > $VERBOSE 2>&1

        if [ $? -eq 1 ]
        then
            warn 'Do you live on Mars? Setting default time zone...'
            default_time
        else
            woutput '[+] Time zone setup correctly'
        fi
    else
        warn 'Setting up default time and timezone to UTC'
        chroot $CHROOT ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
            > $VERBOSE 2>&1
    fi

    return $SUCCESS
}


# mount /proc, /sys and /dev
setup_proc_sys_dev()
{
    title 'Base System Setup > Proc Sys Dev'

    woutput '[+] Setting up /proc, /sys and /dev'
    printf "\n\n"

    mount --types proc /proc "$CHROOT/proc" > $VERBOSE 2>&1
    mount --rbind /sys "$CHROOT/sys" > $VERBOSE 2>&1
    mount --rbind /dev "$CHROOT/dev" > $VERBOSE 2>&1
    mount --bind /run "$CHROOT/run" > $VERBOSE 2>&1

    if [ "$INIT_SYSTEM" = 'systemd' ]
    then
        mount --make-rslave "$CHROOT/sys" > $VERBOSE 2>&1
        mount --make-rslave "$CHROOT/dev" > $VERBOSE 2>&1
        mount --make-slave "$CHROOT/run" > $VERBOSE 2>&1
    fi

    return $SUCCESS
}


# setup hostname
setup_hostname()
{
    title 'Base System Setup > Hostname'

    woutput '[+] Setting up hostname'
    printf "\n\n"

    echo "$HOST_NAME" > "$CHROOT/etc/hostname"

    return $SUCCESS
}


# setup boot loader for UEFI/GPT or BIOS/MBR
setup_bootloader()
{
    ### Set the default resolution for grub and tty
    # resolutionxset="$(xprop -notype -len 8 -root _NET_DESKTOP_GEOMETRY | awk '{print $3}')"
    # resolutionyset="$(xprop -notype -len 16 -root _NET_DESKTOP_GEOMETRY | awk '{print $4}')"

    title 'Base System Setup > Boot Loader'

    woutput '[+] Setting up GRUB boot loader'
    printf "\n\n"

    sed -i '/#GRUB_GFXMODE=/c\GRUB_GFXMODE=auto' "$CHROOT/etc/default/grub"
    sed -i '/#GRUB_GFXPAYLOAD_LINUX=/c\GRUB_GFXPAYLOAD_LINUX=keep' "$CHROOT/etc/default/grub"
    sed -i '/#GRUB_BACKGROUND=/c\GRUB_BACKGROUND=/boot/grub/gentoo-wallpaper.png' "$CHROOT/etc/default/grub"
    cp grub/overdeep-wallpaper.png "$CHROOT/boot/grub/"

    sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"/' "$CHROOT/etc/default/grub"

    if [ "$BOOT_MODE" = 'uefi' ] && [ $DUALBOOT = $TRUE ]
    then
        woutput '[?] Are you installing the system on a USB flash drive [y/n]: '
        read -r usbgrub
        warn 'Installing grub on EFI partition...'
        if [ "$usbgrub" = 'y' ] || [ "$usbgrub" = 'Y' ]
        then
            chroot $CHROOT grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Overdeep OS" --removable
        elif [ "$usbgrub" = 'n' ] || [ "$usbgrub" = 'N' ]
        then
            chroot $CHROOT grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Overdeep OS"
        fi
    elif [ "$BOOT_MODE" = 'uefi' ] && [ $DUALBOOT = $FALSE ]
    then
        woutput '[?] Are you installing the system on a USB flash drive [y/n]: '
        read -r usbgrub
        warn 'Installing grub on EFI partition...'
        if [ "$usbgrub" = 'y' ] || [ "$usbgrub" = 'Y' ]
        then
            chroot $CHROOT grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Overdeep OS" --removable --recheck
        elif [ "$usbgrub" = 'n' ] || [ "$usbgrub" = 'N' ]
        then
            chroot $CHROOT grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Overdeep OS" --recheck
        fi
    elif [ "$BOOT_MODE" = 'legacy' ] && [ $DUALBOOT = $TRUE ]
    then
        warn 'Installing grub on MBR of disk...'
        chroot $CHROOT grub-install "$HD_DEV"
    elif [ "$BOOT_MODE" = 'legacy' ] && [ $DUALBOOT = $FALSE ]
    then
        warn 'Installing grub on MBR of disk...'
        chroot $CHROOT grub-install "$HD_DEV" --recheck
    fi

    chroot $CHROOT grub-mkconfig -o /boot/grub/grub.cfg

    uuid="$(lsblk -o UUID "$ROOT_PART" | sed -n 2p)"

    if [ $LUKS = $TRUE ]
    then
      sed -i "s|quiet|cryptdevice=UUID=$uuid:$CRYPT_ROOT root=/dev/mapper/$CRYPT_ROOT quiet|" \
        "$CHROOT/etc/default/grub"
    fi
    sed -i 's/Arch/BlackArch/g' "$CHROOT/etc/default/grub"
    echo "GRUB_BACKGROUND=\"/boot/grub/splash.png\"" >> \
      "$CHROOT/etc/default/grub"

    sed -i 's/#GRUB_COLOR_/GRUB_COLOR_/g' "$CHROOT/etc/default/grub"

    chroot $CHROOT grub-install --target=i386-pc "$HD_DEV" > $VERBOSE 2>&1

    cp -f "$OVERDEEP_PATH/data/boot/grub/splash.png" "$CHROOT/boot/grub/splash.png"

    chroot $CHROOT grub-mkconfig -o /boot/grub/grub.cfg > $VERBOSE 2>&1


    return $SUCCESS
}


# ask for normal user account to setup
ask_user_account()
{
    if confirm_title 'Base System Setup > User' '[?] Setup a normal user account [y/n]: '
    then
        woutput '[?] User name: '
        read -r NORMAL_USER
    fi

    return $SUCCESS
}


# setup overdeep test user (not active + lxdm issue)
setup_testuser()
{
    title 'Base System Setup > Test User'

    woutput '[+] Setting up test user overdeep account'
    printf "\n\n"
    warn 'Remove this user after you added a normal system user account'
    printf "\n"

    chroot $CHROOT groupadd overdeep > $VERBOSE 2>&1
    chroot $CHROOT useradd -g overdeep -d /home/overdeep/ \
        -s /sbin/nologin -m overdeep > $VERBOSE 2>&1

    return $SUCCESS
}


# setup user account, password and environment
setup_user()
{
    user="$(echo "$1" | tr -dc '[:alnum:]_' | tr '[:upper:]' '[:lower:]' |
        cut -c 1-32)"

    title 'Base System Setup > User'

    woutput "[+] Setting up $user account"
    printf "\n\n"

    # normal user
    if [ -n "$NORMAL_USER" ]
    then
        chroot $CHROOT groupadd "$user" > $VERBOSE 2>&1
        chroot $CHROOT useradd -g "$user" -d "/home/$user" -s "/bin/bash" \
            -G "$user,wheel,users,video,audio" -m "$user" > $VERBOSE 2>&1
        chroot $CHROOT chown -R "$user":"$user" "/home/$user" > $VERBOSE 2>&1
        woutput "[+] Added user: $user"
        printf "\n\n"
        # environment
    elif [ -z "$NORMAL_USER" ]
    then
        cp -r "$OVERDEEP_PATH/data/root/." "$CHROOT/root/." > $VERBOSE 2>&1
    else
        cp -r "$OVERDEEP_PATH/data/user/." "$CHROOT/home/$user/." > $VERBOSE 2>&1
        chroot $CHROOT chown -R "$user":"$user" "/home/$user" > $VERBOSE 2>&1
    fi

    # password
    res=1337
    woutput "[?] Set password for $user: "
    printf "\n\n"
    while [ $res -ne 0 ]
    do
        if [ "$user" = "root" ]
        then
            chroot $CHROOT passwd
        else
            chroot $CHROOT passwd "$user"
        fi
        res=$?
    done

    return $SUCCESS
}


# install extra (missing) packages
setup_extra_packages()
{
    arch='arch-install-scripts pkgfile'

    bluetooth='bluez bluez-hid2hci bluez-tools bluez-utils'

    browser='chromium elinks firefox'

    editor='hexedit nano vim'

    filesystem='cifs-utils dmraid dosfstools exfat-utils f2fs-tools
    gpart gptfdisk mtools nilfs-utils ntfs-3g partclone parted partimage'

    fonts='ttf-dejavu ttf-indic-otf ttf-liberation xorg-fonts-misc'

    hardware='amd-ucode intel-ucode'

    kernel='linux-headers'

    misc='acpi alsa-utils b43-fwcutter bash-completion bc cmake ctags expac
    feh git gpm haveged hdparm htop inotify-tools ipython irssi
    linux-atm lsof mercurial mesa mlocate moreutils mpv p7zip rsync
    rtorrent screen scrot smartmontools strace tmux udisks2 unace unrar
    unzip upower usb_modeswitch usbutils zip zsh'

    network='atftp bind-tools bridge-utils curl darkhttpd dhclient dhcpcd dialog
    dnscrypt-proxy dnsmasq dnsutils fwbuilder gnu-netcat ipw2100-fw ipw2200-fw iw
    iwd lftp nfs-utils ntp openconnect openssh openvpn ppp pptpclient rfkill
    rp-pppoe socat vpnc wget wireless_tools wpa_supplicant wvdial xl2tpd'

    xorg='rxvt-unicode xf86-video-amdgpu xf86-video-ati
    xf86-video-dummy xf86-video-fbdev xf86-video-intel xf86-video-nouveau
    xf86-video-openchrome xf86-video-sisusb xf86-video-vesa xf86-video-vmware
    xf86-video-voodoo xorg-server xorg-xbacklight xorg-xinit xterm'

    all="$arch $bluetooth $browser $editor $filesystem $fonts $hardware $kernel"
    all="$all $misc $network $xorg"

    title 'Base System Setup > Extra Packages'

    woutput '[+] Installing extra packages'
    printf "\n"

    printf "
  > ArchLinux   : %s packages
  > Browser     : %s packages
  > Bluetooth   : %s packages
  > Editor      : %s packages
  > Filesystem  : %s packages
  > Fonts       : %s packages
  > Hardware    : %s packages
  > Kernel      : %s packages
  > Misc        : %s packages
  > Network     : %s packages
  > Xorg        : %s packages\n"
                "$(echo "$arch" | wc -w)" \
                "$(echo "$browser" | wc -w)" \
                "$(echo "$bluetooth" | wc -w)" \
                "$(echo "$editor" | wc -w)" \
                "$(echo "$filesystem" | wc -w)" \
                "$(echo "$fonts" | wc -w)" \
                "$(echo "$hardware" | wc -w)" \
                "$(echo "$kernel" | wc -w)" \
                "$(echo "$misc" | wc -w)" \
                "$(echo "$network" | wc -w)" \
                "$(echo "$xorg" | wc -w)"

    warn 'This can take a while, please wait...'
    printf "\n"

    chroot $CHROOT pacman -S --needed --overwrite='*' --noconfirm "$all" \
        > $VERBOSE 2>&1

    return $SUCCESS
}


# perform system base setup/configurations
setup_base_system()
{
    if [ "$INSTALL_MODE" = "$INSTALL_FULL_ISO" ]
    then
        dump_full_iso
        sleep_clear 1
    fi

    if [ "$INSTALL_MODE" != "$INSTALL_FULL_ISO" ]
    then
        #pass_mirror_conf # copy mirror list to chroot env

        setup_resolvconf
        sleep_clear 1

        install_base_packages
        sleep_clear 1

        setup_resolvconf
        sleep_clear 1
    fi

    setup_fstab
    sleep_clear 1

    setup_proc_sys_dev
    sleep_clear 1

    setup_locale
    sleep_clear 1

    setup_hostname
    sleep_clear 1

    setup_user "root"
    sleep_clear 1

    ask_user_account
    sleep_clear 1

    if [ -n "$NORMAL_USER" ]
    then
        setup_user "$NORMAL_USER"
        sleep_clear 1
    else
        setup_testuser
        sleep_clear 0
    fi

    if [ "$INSTALL_MODE" != "$INSTALL_FULL_ISO" ]
    then
        setup_extra_packages
        sleep_clear 1
    fi

    setup_bootloader
    sleep_clear 1

    return $SUCCESS
}


# enable systemd-networkd services
enable_iwd_networkd()
{
    title 'Overdeep OS Setup > Network'

    woutput '[+] Enabling Iwd and Networkd'
    printf "\n\n"

    chroot $CHROOT systemctl enable iwd systemd-networkd > $VERBOSE 2>&1

    return $SUCCESS
}


# update /etc files and set up iptables
update_etc()
{
    title 'Overdeep OS Setup > Etc files'

    woutput '[+] Updating /etc files'
    printf "\n\n"

    # /etc/*
    cp -r "$OVERDEEP_PATH/data/etc/"{arch-release,issue,motd,\
        os-release,sysctl.d,systemd "$CHROOT/etc/." > $VERBOSE 2>&1

    return $SUCCESS
}


# ask for overdeep linux mirror
ask_mirror()
{
    title 'Overdeep OS Setup > BlackArch Mirror'

    local IFS='|'
    count=1
    mirror_url='https://raw.githubusercontent.com/BlackArch/blackarch/master/mirror/mirror.lst'
    mirror_file='/tmp/mirror.lst'

    woutput '[+] Fetching mirror list'
    printf "\n\n"
    curl -s -o $mirror_file $mirror_url > $VERBOSE

    while read -r country url mirror_name
    do
        woutput " %s. %s - %s" "$count" "$country" "$mirror_name"
        printf "\n"
        woutput "   * %s" "$url"
        printf "\n"
        count=$((count + 1))
    done < "$mirror_file"

    printf "\n"
    woutput '[?] Select a mirror number (enter for default): '
    read -r a
    printf "\n"

    # bugfix: detected chars added sometimes - clear chars
    _a=$(printf "%s" "$a" | sed 's/[a-z]//Ig' 2> /dev/null)

    if [ -z "$_a" ]
    then
        woutput "[+] Choosing default mirror: %s " "$BLACKARCH_REPO_URL"
    else
        BLACKARCH_REPO_URL=$(sed -n "${_a}p" $mirror_file | cut -d "|" -f 2)
        woutput "[+] Mirror from '%s' selected" \
            "$(sed -n "${_a}p" $mirror_file | cut -d "|" -f 3)"
        printf "\n\n"
    fi

    rm -f $mirror_file

    return $SUCCESS
}

# ask for archlinux server
ask_mirror_arch()
{
    local mirrold='cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup'

    if confirm_title 'Pacman Setup > ArchLinux Mirrorlist' \
        "[+] Worldwide mirror will be used\n\n[?] Look for the best server [y/n]: "
    then
        printf "\n"
        warn 'This may take time depending on your connection'
        printf "\n"
        $mirrold
        pacman -Sy --noconfirm > $VERBOSE 2>&1
        pacman -S --needed --noconfirm reflector > $VERBOSE 2>&1
        yes | pacman -Scc > $VERBOSE 2>&1
        reflector --verbose --latest 5 --protocol https --sort rate \
            --save /etc/pacman.d/mirrorlist > $VERBOSE 2>&1
    else
        printf "\n"
        warn 'Using Worldwide mirror server'
        $mirrold
        echo -e "## Arch Linux repository Worldwide mirrorlist\n\n" \
            > /etc/pacman.d/mirrorlist

        for wore in $ARCH_REPO_URL
        do
            echo "Server = $wore" >> /etc/pacman.d/mirrorlist
        done
    fi

    return $SUCCESS
}


# pass correct config
pass_mirror_conf()
{
    mkdir -p "$CHROOT/etc/pacman.d/" > $VERBOSE 2>&1
    cp -f /etc/pacman.d/mirrorlist "$CHROOT/etc/pacman.d/mirrorlist" \
        > $VERBOSE 2>&1

    return $SUCCESS
}


# ask user for display server
ask_display_server()
{
    if confirm_title 'Display Server Setup' '[?] Install a Display Server (Xorg/Wayland) [y/n]: '
    then
        DISPLAY_SERVER_SETUP=$TRUE
    fi

    return $SUCCESS
}


# setup display server
setup_display_server()
{
    title 'Overdeep OS Setup > Desktop'

    woutput '[+] Setting up window managers'
    printf "\n\n"

    while true
    do
        printf "
      WMs:\n\n
      1. Awesome
      2. Fluxbox
      3. Hyprland
      4. I3-wm
      5. Openbox
      6. Spectrwm\n
      DEs:\n\n
      1. Plasma
      2. Gnome
      3. Xfce
      4. Mate
      5. Cinnamon
      6. Enlightenment\n"
        woutput '[?] Choose an option [5]: '
        read -r choice
        echo
        case $choice in
            1)
                break
                ;;
            2)
                break
                ;;
            3)
                break
                ;;
            4)
                break
                ;;
            5)
                break
                ;;
        esac
    done

    # wallpaper
    cp -r "$OVERDEEP_PATH/data/usr/share/blackarch" "$CHROOT/usr/share/blackarch"

    return $SUCCESS
}


# setup display manager
setup_display_manager()
{
    title 'Overdeep OS Setup > Display Manager'

    woutput '[+] Setting up LXDM'
    printf "\n\n"

    # install lxdm packages
    chroot $CHROOT pacman -S lxdm --needed --overwrite='*' --noconfirm \
        > $VERBOSE 2>&1

    # config files
    cp -r "$OVERDEEP_PATH/data/etc/X11" "$CHROOT/etc/."
    cp -r "$OVERDEEP_PATH/data/etc/xprofile" "$CHROOT/etc/."
    cp -r "$OVERDEEP_PATH/data/etc/lxdm/." "$CHROOT/etc/lxdm/."
    cp -r "$OVERDEEP_PATH/data/usr/share/lxdm/." "$CHROOT/usr/share/lxdm/."
    cp -r "$OVERDEEP_PATH/data/usr/share/gtk-2.0/." "$CHROOT/usr/share/gtk-2.0/."
    mkdir -p "$CHROOT/usr/share/xsessions"

    # enable in systemd
    chroot $CHROOT systemctl enable lxdm > $VERBOSE 2>&1

    return $SUCCESS
}


# ask user for VirtualBox modules+utils setup
ask_vbox_setup()
{
    if confirm_title 'Overdeep OS Setup > VirtualBox' '[?] Setup VirtualBox modules [y/n]: '
    then
        VBOX_SETUP=$TRUE
    fi

    return $SUCCESS
}


# setup virtualbox utils
setup_vbox_utils()
{
    title 'Overdeep OS Setup > VirtualBox'

    woutput '[+] Setting up VirtualBox utils'
    printf "\n\n"

    chroot $CHROOT pacman -S virtualbox-guest-utils --overwrite='*' --needed \
        --noconfirm > $VERBOSE 2>&1

    chroot $CHROOT systemctl enable vboxservice > $VERBOSE 2>&1

    #printf "vboxguest\nvboxsf\nvboxvideo\n" \
        #  > "$CHROOT/etc/modules-load.d/vbox.conf"

    cp -r "$OVERDEEP_PATH/data/etc/xdg/autostart/vboxclient.desktop" \
        "$CHROOT/etc/xdg/autostart/." > $VERBOSE 2>&1

    return $SUCCESS
}


# ask user for VirtualBox modules+utils setup
ask_vmware_setup()
{
    if confirm_title 'Overdeep OS Setup > VMware' '[?] Setup VMware modules [y/n]: '
    then
        VMWARE_SETUP=$TRUE
    fi

    return $SUCCESS
}


# setup vmware utils
setup_vmware_utils()
{
    title 'Overdeep OS Setup > VMware'

    woutput '[+] Setting up VMware utils'
    printf "\n\n"

    chroot $CHROOT pacman -S open-vm-tools xf86-video-vmware \
        xf86-input-vmmouse --overwrite='*' --needed --noconfirm \
        > $VERBOSE 2>&1
    chroot $CHROOT systemctl enable vmware-vmblock-fuse.service > $VERBOSE 2>&1
    chroot $CHROOT systemctl enable vmtoolsd.service > $VERBOSE 2>&1

    return $SUCCESS
}


# ask user for  tools setup
ask_overdeep_tools_setup()
{
    if confirm_title 'Overdeep OS Setup > Tools' '[?] Setup Overdeep OS tools [y/n]: '
    then
        OVERDEEP_TOOLS_SETUP=$TRUE
    fi

    return $SUCCESS
}


# setup overdeep tools from repository (binary) or via source
setup_overdeep_tools()
{
    foo=5

    if [ "$VERBOSE" = '/dev/null' ]
    then
        noconfirm='--noconfirm'
    fi

    title 'Overdeep OS Setup > Tools'

    woutput '[+] Installing Overdeep OS packages (grab a coffee)'
    printf "\n\n"

    if [ "$INSTALL_MODE" = $INSTALL_STAGE ]
    then
        woutput "[+] All available BlackArch tools groups:\n\n"
        printf "    > blackarch blackarch-anti-forensic blackarch-automation
      > blackarch-backdoor blackarch-binary blackarch-bluetooth blackarch-code-audit
      > blackarch-cracker blackarch-crypto blackarch-database blackarch-debugger
      > blackarch-decompiler blackarch-defensive blackarch-disassembler
      > blackarch-dos blackarch-drone blackarch-exploitation blackarch-fingerprint
      > blackarch-firmware blackarch-forensic blackarch-fuzzer blackarch-hardware
      > blackarch-honeypot blackarch-ids blackarch-keylogger blackarch-malware
      > blackarch-misc blackarch-mobile blackarch-networking blackarch-nfc
      > blackarch-packer blackarch-proxy blackarch-recon blackarch-reversing
      > blackarch-scanner blackarch-sniffer blackarch-social blackarch-spoof
      > blackarch-threat-model blackarch-tunnel blackarch-unpacker blackarch-voip
      > blackarch-webapp blackarch-windows blackarch-wireless \n\n"
        woutput "[?] BlackArch groups to install (space for multiple) [blackarch]: "
        read -r BA_GROUPS
        printf "\n"
        warn 'This can take a while, please wait...'
        if [ -z "$BA_GROUPS" ]
        then
            printf "\n"
            check_space
            printf "\n\n"
            chroot $CHROOT pacman -S --needed --noconfirm --overwrite='*' blackarch \
                > $VERBOSE 2>&1
        else
            chroot $CHROOT pacman -S --needed --noconfirm --overwrite='*' "$BA_GROUPS" \
                > $VERBOSE 2>&1
        fi
    else
        warn 'Installing all tools from source via blackman can take hours'
        printf "\n"
        woutput '[+] <Control-c> to abort ... '
        while [ $foo -gt 0 ]
        do
            woutput "$foo "
            sleep 1
            foo=$((foo - 1))
        done
        printf "\n"
        chroot $CHROOT pacman -S --needed --overwrite='*' "$noconfirm" blackman \
            > $VERBOSE 2>&1
        chroot $CHROOT blackman -a > $VERBOSE 2>&1
    fi

    return $SUCCESS
}


# add user to newly created groups
update_user_groups()
{
    title 'Overdeep OS Setup > User'

    woutput "[+] Adding user $user to groups and sudoers"
    printf "\n\n"

    # TODO: more to add here
    if [ $VBOX_SETUP -eq $TRUE ]
    then
        chroot $CHROOT usermod -aG 'vboxsf,audio,video' "$user" > $VERBOSE 2>&1
    fi

    # sudoers
    echo "$user ALL=(ALL) ALL" >> $CHROOT/etc/sudoers > $VERBOSE 2>&1

    return $SUCCESS
}


# dump data from the full-iso
dump_full_iso()
{
    full_dirs='/bin /sbin /etc /home /lib /lib64 /opt /root /srv /usr /var /tmp'
    total_size=0 # no cheat

    title 'Overdeep OS Setup'

    woutput '[+] Dumping data from Full-ISO. Grab a coffee and pop shells!'
    printf "\n\n"

    woutput '[+] Fetching total size to transfer, please wait...'
    printf "\n"

    for d in $full_dirs
    do
        part_size=$(du -sm "$d" 2> /dev/null | awk '{print $1}')
        ((total_size+=part_size))
        printf "
        %s" "> $d $part_size MB"
    done
    printf "\n
    %s
    \n\n" "[ Total size = $total_size MB ]"

    check_space

    woutput '[+] Installing the system to /'
    printf "\n\n"
    warn 'This can take a while, please wait...'
    printf "\n"
    rsync -aWx --human-readable --info=progress2 / $CHROOT > $VERBOSE 2>&1
    woutput "[+] Installation done!\n"

    # clean up files
    woutput '[+] Cleaning Full Environment files, please wait...'
    #sed -i 's/Storage=volatile/#Storage=auto/' ${CHROOT}/etc/systemd/journald.conf
    #rm -rf "$CHROOT/etc/udev/rules.d/81-dhcpcd.rules"
    #rm -rf "$CHROOT/etc/systemd/system/"{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
    #rm -rf "$CHROOT/etc/systemd/scripts/choose-mirror"
    #rm -rf "$CHROOT/etc/systemd/system/getty@tty1.service.d/autologin.conf"
    #rm -rf "$CHROOT/root/"{.automated_script.sh,.zlogin}
    #rm -rf "$CHROOT/etc/mkinitcpio-archiso.conf"
    #rm -rf "$CHROOT/etc/initcpio"
    #rm -rf ${CHROOT}/etc/{group*,passwd*,shadow*,gshadow*}
    woutput "done\n"

    return $SUCCESS
}


# setup overdeep-os related stuff
setup_overdeep()
{
    update_etc
    sleep_clear 1

    enable_iwd_networkd
    sleep_clear 1

    ask_mirror
    sleep_clear 1

    ask_x_setup
    sleep_clear 3

    if [ $DISPLAY_SERVER_SETUP -eq $TRUE ]
    then
        setup_display_manager
        sleep_clear 1
        setup_full_desktop
        sleep_clear 1
    fi

    ask_vbox_setup
    sleep_clear 1

    if [ $VBOX_SETUP -eq $TRUE ]
    then
        setup_vbox_utils
        sleep_clear 1
    fi

    ask_vmware_setup
    sleep_clear 1

    if [ $VMWARE_SETUP -eq $TRUE ]
    then
        setup_vmware_utils
        sleep_clear 1
    fi

    sleep_clear 1

    enable_pacman_multilib 'chroot'
    sleep_clear 1

    enable_pacman_color 'chroot'
    sleep_clear 1

    ask_overdeep_tools_setup
    sleep_clear 1

    if [ $OVERDEEP_TOOLS_SETUP -eq $TRUE ]
    then
        setup_overdeep_tools
        sleep_clear 1
    fi

    if [ -n "$NORMAL_USER" ]
    then
        update_user_groups
        sleep_clear 1
    fi

    return $SUCCESS
}


# for fun and lulz
easter_backdoor()
{
    bar=0

    title 'Installation Finished!'

    woutput "[+] $DISTRO_NAME installation successfull!"
    printf "\n\n"

    while [ $bar -ne 5 ]
    do
        woutput "."
        sleep 1
        bar=$((bar + 1))
    done
    printf "%s" " >> ${BLINK}${BLUE}HACK THE PLANET! D00R THE PLANET!${NC} <<"
    printf "\n\n"

    return $SUCCESS
}


# perform sync
sync_disk()
{
    title 'Game Over'

    woutput '[+] Syncing disk'
    printf "\n\n"

    sync

    return $SUCCESS
}


# controller and program flow
main()
{
    # do some ENV checks
    sleep_clear 0
    check_uid
    check_boot_mode
    check_init_system

    # check for net connection
    check_internet
    sleep_clear 0

    # check for updates
    self_updater
    sleep_clear 0
  
    # output mode
    ask_output_mode
    sleep_clear 0

    # locale
    ask_locale
    sleep_clear 0
    set_locale
    sleep_clear 0
    if [ "$CUR_INIT_SYSTEM" = 'systemd' ]
    then
        set_current_locale
        sleep_clear 0
    fi
  
    # keymap
    ask_keymap
    sleep_clear 0
    set_keymap
    sleep_clear 0
    if [ "$CUR_INIT_SYSTEM" = 'systemd' ]
    then
        set_current_keymap
        sleep_clear 0
    fi

    # network
    ask_hostname
    sleep_clear 0

    if [ "$INSTALL_MODE" != "$INSTALL_FULL_ISO" ]
    then
        get_net_ifs
        ask_net_conf_mode
        if [ "$NET_CONF_MODE" != "$NET_CONF_SKIP" ]
        then
            ask_net_if
        fi
        case "$NET_CONF_MODE" in
            "$NET_CONF_AUTO")
                net_conf_auto
                ;;
            "$NET_CONF_WLAN")
                ask_wlan_data
                net_conf_wlan
                ;;
            "$NET_CONF_MANUAL")
                ask_net_addr
                net_conf_manual
                ;;
            "$NET_CONF_SKIP")
                ;;
            *)
                ;;
        esac
        sleep_clear 1
        check_internet
        sleep_clear 1

        # self updater
        # self_updater
        # sleep_clear 0
    fi

    # hard drive
    get_hd_devs
    ask_hd_dev
    ask_dualboot
    sleep_clear 1
    umount_filesystems 'harddrive'
    sleep_clear 1
    ask_cfdisk
    sleep_clear 3
    ask_luks
    sleep_clear 0
    get_partition_label
    ask_partitions
    if [ $BTRFS_SUBVOL -eq $TRUE ]
    then
        ask_btrfs_subvol
    fi
    confirm_all
    sleep_clear 1
    make_partitions
    sleep_clear 1
    mount_filesystems
    sleep_clear 1

    # arch linux
    setup_base_system
    sleep_clear 1
    setup_time
    sleep_clear 1

    # overdeep install mode
    if [ "$INSTALL_MODE" != "$INSTALL_FULL_ISO" ]
    then
        setup_overdeep
        sleep_clear 1
    fi

    # epilog
    umount_filesystems
    sleep_clear 1
    sync_disk
    sleep_clear 1
    easter_backdoor

    return $SUCCESS
}


# we start here
main "$@"


# EOF
