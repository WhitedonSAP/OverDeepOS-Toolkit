#!/usr/bin/env bash
#######################################################################################
#                                                                                     #
#  Umount.sh - for use with Gentoo-Linux-Installer (GLI)                              #
#                                                                                     #
#  By                                                                                 #
#  WhitedonSAP (whitedon) - ayrtonarantes0987654321ayrt008@gmail.com                  #
#                                                                                     #
#######################################################################################

#################################### Colors ###########################################

### Steps
magentab="$(tput bold ; tput setaf 5)"

### NoColor
nc="$(tput sgr0)"

################################ Starting Script ######################################

#######
#clear
sleep 2
echo -e "\n${magentab}Umounting the System...${nc}\n"
sleep 2
#######

cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo

#######
#clear
sleep 2
echo -e "\n${magentab}Alright, thank you for use this script!!!${nc}\n"
sleep 2
#######
