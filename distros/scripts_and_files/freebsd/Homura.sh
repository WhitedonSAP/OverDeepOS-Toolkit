#!/bin/bash
NAME=Homura
VER=1.8
WINEVER=$(wine --version)

echo -e "\e[32mCopyright (c) 2019, Alexander Vereeken All rights reserved."
echo -e "\e[93mWelcome to $NAME $VER have fun!"
echo -e "\e[3;5;0;92mRunning on FreeBSD $(uname -r)"
echo -e "\e[3;5;0;36mWine Version: $WINEVER\e[30;48;5;82m\e[0m"
echo -e "\e[3;5;0;31mGPU Info OpenGL:\e[30;48;5;82m\e[0m" && glxinfo | grep OpenGL
echo -e "\e[3;5;0;31mGPU Info Vulkan:\e[30;48;5;82m\e[0m" && vulkaninfo | grep "GPU id"

TODO=$(zenity --list --radiolist --height=300 --width 300 --title="$NAME $VER" --text "What do you want to do?" --hide-header --column "$NAME" --column "Item" FALSE "Installation" FALSE "Launcher" FALSE "Uninstallation" FALSE "Winetricks" FALSE "Run a executable in prefix" FALSE "Update" FALSE "Open Homura Folder" FALSE "About" FALSE "Exit")

if [[ $TODO == *"Installation"* ]]; then

INST=$(zenity --list --radiolist --height=430 --width 300 --title="$NAME $VER - $TODO" --text "What do you want to install?" --hide-header --column "$NAME $VER" --column "Item" FALSE "Steam" FALSE "Blizzard" FALSE "Origin" FALSE "Uplay" FALSE "Teamspeak" FALSE "Clone Hero" FALSE "Drakensang Online" FALSE "Anarchy Online" FALSE "itch" FALSE "GOG Galaxy" FALSE "League of Legends" FALSE "Wargaming Game Center" FALSE "Growtopia" FALSE "Custom Prefix" FALSE "Extras for games")

if [[ $INST == *"Steam"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Steam\007'
mkdir -p /home/$USER/.local/share/$NAME/Games/$INST
cd /home/$USER/.local/share/$NAME/Games/$INST
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "SteamSetup.exe" "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mSetup prefix\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST winetricks winxp dotnet40
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST wine /home/$USER/.local/share/$NAME/Games/Steam/SteamSetup.exe
rm /home/$USER/.local/share/$NAME/Games/$INST/SteamSetup.exe
fi

if [[ $INST == *"Blizzard"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Blizzard\007'
mkdir -p /home/$USER/.local/share/$NAME/Games/$INST
cd /home/$USER/.local/share/Homura/Games/$INST
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "Battle.net-Setup-enUS.exe" "http://dist.blizzard.com/downloads/bna-installers/322d5bb9ae0318de3d4cde7641c96425/retail.1/Battle.net-Setup-enUS.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST wine /home/$USER/.local/share/$NAME/Games/$INST/Battle.net-Setup-enUS.exe
rm /home/$USER/.local/share/$NAME/Games/$INST/Battle.net-Setup-enUS.exe
fi

if [[ $INST == *"Origin"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Origin\007'
mkdir -p /home/$USER/.local/share/$NAME/Games/$INST
cd /home/$USER/.local/share/$NAME/Games/$INST
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "OriginThinSetup.exe" "https://origin-a.akamaihd.net/Origin-Client-Download/origin/legacy/OriginThinSetup.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mSetup prefix\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/Origin winetricks winxp
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST wine /home/$USER/.local/share/$NAME/Games/$INST/OriginThinSetup.exe
rm /home/$USER/.local/share/$NAME/Games/$INST/OriginThinSetup.exe
zenity --info --width=310 --title="$NAME $VER - Origin" --text="Dont forget to disable the Origin in-game overlay or you are unable to start a game."
fi

if [[ $INST == *"Uplay"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Uplay\007'
mkdir -p /home/$USER/.local/share/$NAME/Games/$INST
cd /home/$USER/.local/share/$NAME/Games/$INST
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "UplayInstaller.exe" "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UplayInstaller.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST wine /home/$USER/.local/share/$NAME/Games/$INST/UplayInstaller.exe
rm /home/$USER/.local/share/$NAME/Games/$INST/UplayInstaller.exe
fi

if [[ $INST == *"Teamspeak"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Teamspeak\007'
mkdir -p /home/$USER/.local/share/$NAME/Programs/$INST
cd /home/$USER/.local/share/$NAME/Programs/$INST
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "Teamspeak.zip" "http://alt.magzu.net/damn/dl/Teamspeak.zip" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
unzip Teamspeak.zip
rm Teamspeak.zip
zenity --info --width=260 --title="$NAME $VER - Installation of Teamspeak" --text="To get Playback and Capture working set both mods to Direct Sound."
echo -e "\e[40;38;5;82mUpdate to latest version\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Programs/Teamspeak wine "/home/$USER/.local/share/$NAME/Programs/Teamspeak/TeamSpeak 3 Client/update.exe"
fi

if [[ $INST == *"Clone Hero"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Clone Hero\007'
mkdir -p "/home/$USER/.local/share/$NAME/Games/$INST"
cd "/home/$USER/.local/share/$NAME/Games/$INST"
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "clonehero-win32.7z" "http://dl.clonehero.net/clonehero-v.22.5/clonehero-win32.7z" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mSetup prefix\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$INST" winetricks arial
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
7z x clonehero-win32.7z
rm clonehero-win32.7z
echo -e "\e[40;38;5;82mApplying fix\e[30;48;5;82m\e[0m"
cd clonehero-win32
curl -O http://alt.magzu.net/dl/settings.ini
fi

if [[ $INST == *"Drakensang Online"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Drakensang Online\007'
mkdir -p "/home/$USER/.local/share/$NAME/Games/$INST"
cd "/home/$USER/.local/share/$NAME/Games/$INST"
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "dro_setup.exe" "https://drasaonline-481-dwl.bpsecure.com/applet/dro_setup.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/Drakensang Online" wine "/home/$USER/.local/share/$NAME/Games/Drakensang Online/dro_setup.exe"
rm "/home/$USER/.local/share/$NAME/Games/Drakensang Online/dro_setup.exe"
fi

if [[ $INST == *"Anarchy Online"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Anarchy Online\007'
mkdir -p "/home/$USER/.local/share/$NAME/Games/$INST"
cd "/home/$USER/.local/share/$NAME/Games/$INST"
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "AnarchyOnline_EP1.exe" "http://update.anarchy-online.com/download/AO/AnarchyOnline_EP1.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mSetup prefix\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/Anarchy Online" winetricks winxp
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
zenity --info --width=260 --title="$NAME $VER - Installation of Anarchy Online" --text="Please let the installer create an shortcut or you will unable to start the launcher later."
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/Anarchy Online" wine "/home/$USER/.local/share/$NAME/Games/Anarchy Online/AnarchyOnline_EP1.exe"
rm "/home/$USER/.local/share/$NAME/Games/Anarchy Online/AnarchyOnline_EP1.exe"
fi

if [[ $INST == *"itch"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of itch\007'
mkdir -p /home/$USER/.local/share/$NAME/Games/$INST
cd /home/$USER/.local/share/$NAME/Games/$INST
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -L -o "windows" "http://nuts.itch.zone/download/windows" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST wine /home/$USER/.local/share/$NAME/Games/$INST/windows
rm /home/$USER/.local/share/$NAME/Games/$INST/windows
fi

if [[ $INST == *"GOG Galaxy"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of GOG Galaxy\007'
mkdir -p "/home/$USER/.local/share/$NAME/Games/$INST"
cd "/home/$USER/.local/share/$NAME/Games/$INST"
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "setup_galaxy_1.2.54.23.exe" "https://cdn.gog.com/open/galaxy/client/setup_galaxy_1.2.54.23.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$INST" wine "/home/$USER/.local/share/$NAME/Games/$INST/setup_galaxy_1.2.54.23.exe"
rm "/home/$USER/.local/share/$NAME/Games/$INST/setup_galaxy_1.2.54.23.exe"
fi

if [[ $INST == *"League of Legends"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of League of Legends\007'
mkdir -p "/home/$USER/.local/share/$NAME/Games/$INST"
cd "/home/$USER/.local/share/$NAME/Games/$INST"
echo -e "\e[40;38;5;82mDownloading $INST\e[30;48;5;82m\e[0m"
curl -o "League%20of%20Legends.tar.xz" "http://alt.magzu.net/damn/dl/League%20of%20Legends.tar.xz" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
tar -xf League%20of%20Legends.tar.xz
rm League%20of%20Legends.tar.xz
fi

if [[ $INST == *"Wargaming Game Center"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Wargaming Game Center\007'
mkdir -p "/home/$USER/.local/share/$NAME/Games/$INST"
cd "/home/$USER/.local/share/$NAME/Games/$INST"
curl -L -o "Wargaming_Game_Center_Install_EU.exe" "http://redirect.wargaming.net/WGC/Wargaming_Game_Center_Install_EU.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mSetup prefix\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$INST" winetricks vcrun2015
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$INST" winetricks win7
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$INST" wine "/home/$USER/.local/share/$NAME/Games/$INST/Wargaming_Game_Center_Install_EU.exe"
rm "/home/$USER/.local/share/$NAME/Games/$INST/Wargaming_Game_Center_Install_EU.exe"
fi

if [[ $INST == *"Growtopia"* ]]; then
echo $'\033]30;Homura 1.8 - Installation of Growtopia\007'
mkdir -p /home/$USER/.local/share/$NAME/Games/$INST
cd /home/$USER/.local/share/$NAME/Games/$INST
curl -L -o "Growtopia-Installer.exe" "https://growtopiagame.com/Growtopia-Installer.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --text "Downloading $INST" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$INST wine /home/$USER/.local/share/$NAME/Games/$INST/Growtopia-Installer.exe
rm /home/$USER/.local/share/$NAME/Games/$INST/Growtopia-Installer.exe
fi

if [[ $INST == *"Custom Prefix"* ]]; then
echo $'\033]30;Homura Installation of Custom Prefix\007'
PREFIXNAME=$(zenity --title="Create a custom prefix" --text "How your prefix should be called?" --entry --width=260) 
mkdir -p "/home/$USER/.local/share/$NAME/Custom Prefixes"
mkdir -p "/home/$USER/.local/share/$NAME/Custom Prefixes/$PREFIXNAME"
cd "/home/$USER/.local/share/$NAME/Custom Prefixes/$PREFIXNAME"
zenity --info --width=260 --title="Create a custom prefix" --text="Now you need to select the executable that do you want to use in this prefix."
EXECUTABLE="$(zenity --file-selection --title="Choose your executable")"
ENV=$(zenity --title="Environment variable" --text "Do you need an environment variable for your executable? (for example DXVK_HUD=1) if not leave it blank." --entry --width=260) 
SPM=$(zenity --title="Environment variable" --text "Do you need an startparameter for your executable? (for example -console) if not leave it blank." --entry --width=260) 
echo "$ENV WINEPREFIX='/home/$USER/.local/share/$NAME/Custom Prefixes/$PREFIXNAME' wine '$EXECUTABLE' $SPM" >> start.sh
fi

if [[ $INST == *"Extras for games"* ]]; then
EXFG=$(zenity --list --radiolist --height=100 --width=310  --title="$NAME $VER - $INST" --text "What extra do you want to install?" --hide-header --column "$NAME $VER" --column "Item" FALSE "Torchlight German Patch")

if [[ $EXFG == *"Torchlight German Patch"* ]]; then
echo $'\033]30;Torchlight German Patch\007'
TGPH=$(zenity --list --radiolist --height=100 --width=360 --title="$NAME $VER $EXFG" --text "What version?" --hide-header --column "$NAME $VER" --column "Item" FALSE "German Patch V3 (Steam-Edition)" FALSE "German Patch V5 (GOG/Epic-Edition)")

cd /home/$USER/.local/share/$NAME

if [[ $TGPH == *"German Patch V3 (Steam-Edition)"* ]]; then
echo -e "\e[40;38;5;82mDownloading $TGPH\e[30;48;5;82m\e[0m"
curl -o "Torchlight_GerPatchV3_Steam.zip" "http://alt.magzu.net/damn/dl/Torchlight_GerPatchV3_Steam.zip" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $TGPH" --title "$NAME $VER $TODO $TGPH"
unzip Torchlight_GerPatchV3_Steam.zip
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/Steam wine /home/$USER/.local/share/$NAME/Torchlight_GerPatchV3_Steam.exe
rm Torchlight_GerPatchV3_Steam.exe
rm Torchlight_GerPatchV3_Steam.zip
fi

if [[ $TGPH == *"German Patch V5 (GOG/Epic-Edition)"* ]]; then
echo -e "\e[40;38;5;82mDownloading $TGPH\e[30;48;5;82m\e[0m"
curl -o "Torchlight_GerPatchV5_GOGEPIC.zip" "http://alt.magzu.net/damn/dl/Torchlight_GerPatchV5_GOGEPIC.zip" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --auto-close --text "Downloading $TGPH" --title "$NAME $VER $TODO $TGPH"
unzip Torchlight_GerPatchV5_GOGEPIC.zip
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/GOG Galaxy" wine /home/$USER/.local/share/$NAME/Torchlight_GerPatchV5_GOGEPIC.exe
rm Torchlight_GerPatchV5_GOGEPIC.exe
rm Torchlight_GerPatchV5_GOGEPIC.zip
fi
fi
fi
fi

if [[ $TODO == *"Launcher"* ]]; then
LNCH=$(zenity --list --radiolist --height=410 --width 300 --title="$NAME $VER - $TODO" --text "What do you want to launch?" --hide-header --column "$NAME $VER" --column "Item" FALSE "Steam" FALSE "Blizzard" FALSE "Origin" FALSE "Uplay" FALSE "Teamspeak" FALSE "Clone Hero" FALSE "Drakensang Online" FALSE "Anarchy Online" FALSE "itch" FALSE "GOG Galaxy" FALSE "League of Legends" FALSE "Wargaming Game Center" FALSE "Growtopia" FALSE "Custom Prefix")

if [[ $LNCH == *"Steam"* ]]; then
echo $'\033]30;Steam\007'        
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$LNCH wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/Steam/Steam.exe" -no-cef-sandbox
fi

if [[ $LNCH == *"Blizzard"* ]]; then
echo $'\033]30;Blizzard\007'
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$LNCH wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/Battle.net/Battle.net.exe"
fi

if [[ $LNCH == *"Origin"* ]]; then
echo $'\033]30;Origin\007'
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$LNCH wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/Origin/Origin.exe"
fi

if [[ $LNCH == *"Uplay"* ]]; then
echo $'\033]30;Uplay\007'
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$LNCH wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/Ubisoft/Ubisoft Game Launcher/Uplay.exe"
fi

if [[ $LNCH == *"Teamspeak"* ]]; then
echo $'\033]30;Teamspeak\007'
WINEPREFIX=/home/$USER/.local/share/$NAME/Programs/$LNCH wine "/home/$USER/.local/share/$NAME/Programs/$LNCH/TeamSpeak 3 Client/ts3client_win32.exe"
fi

if [[ $LNCH == *"Clone Hero"* ]]; then
echo $'\033]30;Clone Hero\007'
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$LNCH" wine "/home/$USER/.local/share/$NAME/Games/$LNCH/clonehero-win32/Clone Hero.exe"
fi

if [[ $LNCH == *"Drakensang Online"* ]]; then
echo $'\033]30;Drakensang Online\007'
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$LNCH" wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/Drakensang Online/thinclient.exe"
fi

if [[ $LNCH == *"Anarchy Online"* ]]; then
echo $'\033]30;Anarchy Online\007'
env WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$LNCH" wine C:\\windows\\command\\start.exe /Unix /home/$USER/.local/share/$NAME/Games/Anarchy\ Online/dosdevices/c:/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Anarchy\ Online/Anarchy\ Online.lnk
fi

if [[ $LNCH == *"itch"* ]]; then
echo $'\033]30;itch\007'
ITCHVER=25.4.0
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$LNCH wine "/home/$USER/.wine/drive_c/users/$USER/Local Settings/Application Data/itch/app-$ITCHVER/itch.exe"
fi

if [[ $LNCH == *"GOG Galaxy"* ]]; then
echo $'\033]30;GOG Galaxy\007'
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$LNCH" wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/GOG Galaxy/GalaxyClient.exe" /runWithoutUpdating /deelevated
fi

if [[ $LNCH == *"League of Legends"* ]]; then
echo $'\033]30;League of Legends\007'
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$LNCH" wine "/home/$USER/.local/share/$NAME/Games/$LNCH/League of Legends/LeagueClient.exe"
fi

if [[ $LNCH == *"Wargaming Game Center"* ]]; then
echo $'\033]30;Wargaming Game Center\007'
WINEPREFIX="/home/$USER/.local/share/$NAME/Games/$LNCH" wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/Program Files/Wargaming.net/GameCenter/wgc.exe"
fi

if [[ $LNCH == *"Growtopia"* ]]; then
echo $'\033]30;Growtopia\007'
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$LNCH wine "/home/$USER/.local/share/$NAME/Games/$LNCH/drive_c/users/$USER/Local Settings/Application Data/Growtopia/Growtopia.exe"
fi

if [[ $LNCH == *"Custom Prefix"* ]]; then
echo $'\033]30;Custom Prefix\007'
cd "/home/$USER/.local/share/$NAME/Custom Prefixes"
FOLDERS=$(ls -a)
PREFIXNAME=$(zenity --list --title="Launch a custom prefix" --height=260 --width=300 --column="What do you want to start?" $FOLDERS)
echo $'\033]30;$PREFIXNAME\007'
bash $PREFIXNAME/start.sh
fi
fi

if [[ $TODO == *"Uninstallation"* ]]; then
UNST=$(zenity --list --radiolist --height=410 --width 300 --title="$NAME $VER - $TODO" --text "What do you want to uninstall?" --hide-header --column "$NAME" --column "Item" FALSE "Steam" FALSE "Blizzard" FALSE "Origin" FALSE "Uplay" FALSE "Teamspeak" FALSE "Clone Hero" FALSE "Drakensang Online" FALSE "Anarchy Online" FALSE "itch" FALSE "GOG Galaxy" FALSE "League of Legends" FALSE "Wargaming Game Center" FALSE "Growtopia" FALSE "Custom Prefix")

if [[ $UNST == *"Steam"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Games/$UNST
rm -d -r /home/$USER/.local/share/applications/wine/Programs/$UNST
rm /home/$USER/Desktop/$UNST.desktop
fi

if [[ $UNST == *"Blizzard"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Games/$UNST
rm -d -r /home/$USER/.local/share/applications/wine/Programs/Battle.net
rm -d -r /home/$USER/Desktop/Battle.net.desktop
fi

if [[ $UNST == *"Origin"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Games/$UNST
rm -d -r /home/$USER/.local/share/applications/wine/Programs/$UNST
rm /home/$USER/Desktop/$UNST.desktop
fi

if [[ $UNST == *"Uplay"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Games/$UNST
rm -d -r /home/$USER/.local/share/applications/wine/Programs/Ubisoft
rm /home/$USER/Desktop/$UNST.desktop
rm /home/$USER/Desktop/$UNST.lnk 
fi

if [[ $UNST == *"Teamspeak"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Programs/$UNST
fi

if [[ $UNST == *"Clone Hero"* ]]; then
rm -d -r "/home/$USER/.local/share/$NAME/Games/$UNST"
fi

if [[ $UNST == *"Drakensang Online"* ]]; then
rm -d -r "/home/$USER/.local/share/$NAME/Games/$UNST"
rm -d -r "/home/$USER/.local/share/applications/wine/Programs/$UNST"
rm "/home/$USER/Desktop/$UNST.desktop"
rm "/home/$USER/Desktop/$UNST.lnk"
fi

if [[ $UNST == *"Anarchy Online"* ]]; then
rm -d -r "/home/$USER/.local/share/$NAME/Games/$UNST"
rm -d -r "/home/$USER/.local/share/applications/wine/Programs/$UNST"
rm "/home/$USER/Desktop/$UNST.desktop"
fi

if [[ $UNST == *"itch"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Games/$UNST
rm -d -r "/home/$USER/.local/share/applications/wine/Programs/Itch Corp"
fi

if [[ $UNST == *"GOG Galaxy"* ]]; then
rm -d -r "/home/$USER/.local/share/$NAME/Games/$UNST"
rm -d -r /home/$USER/.local/share/applications/wine/Programs/GOG.com
rm -d -r "/home/$USER/Desktop/$UNST.desktop"
fi

if [[ $UNST == *"League of Legends"* ]]; then
rm -d -r "/home/$USER/.local/share/$NAME/Games/$UNST"
fi

if [[ $UNST == *"Wargaming Game Center"* ]]; then
rm -d -r "/home/$USER/.local/share/$NAME/Games/$UNST"
rm -d -r /home/$USER/.local/share/applications/wine/Programs/Wargaming.net
rm /home/$USER/Desktop/Game Center.desktop
fi

if [[ $UNST == *"Growtopia"* ]]; then
rm -d -r /home/$USER/.local/share/$NAME/Games/$UNST
rm -d -r /home/$USER/.local/share/applications/wine/Programs/$UNST
rm /home/$USER/Desktop/Growtopia.desktop
fi

if [[ $UNST == *"Custom Prefix"* ]]; then
cd "/home/$USER/.local/share/$NAME/Custom Prefixes"
FOLDERS=$(ls -a)
PREFIXNAME=$(zenity --list --title="$NAME $VER - Select a custom prefix" --height=260 --width=300 --column="What prefix?" $FOLDERS)
rm -r -d "$PREFIXNAME"
fi
fi

if [[ $TODO == *"Winetricks"* ]]; then
WTR=$(zenity --list --radiolist --height=410 --title="$NAME $VER - $TODO" --text "In what prefix do you want to open winetricks?" --hide-header --column "$NAME" --column "Item" FALSE "Steam" FALSE "Blizzard" FALSE "Origin" FALSE "Uplay" FALSE "Teamspeak" FALSE "Clone Hero" FALSE "Drakensang Online" FALSE "Anarchy Online" FALSE "itch" FALSE "GOG Galaxy" FALSE "League of Legends" FALSE "Wargaming Game Center" FALSE "Growtopia" FALSE "Custom Prefix")

if [[ $WTR == *"Steam"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Blizzard"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Origin"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Uplay"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Teamspeak"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Clone Hero"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Drakensang Online"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Anarchy Online"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"itch"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"GOG Galaxy"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"League of Legends"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Wargaming Game Center"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Growtopia"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$WTR winetricks
fi

if [[ $WTR == *"Custom Prefix"* ]]; then
cd "/home/$USER/.local/share/$NAME/Custom Prefixes"
FOLDERS=$(ls -a)
PREFIXNAME=$(zenity --list --title="$NAME $VER - Select a custom prefix" --height=260 --width=300 --column="What prefix?" $FOLDERS)
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$PREFIXNAME winetricks
fi
fi

if [[ $TODO == *"Run a executable in prefix"* ]]; then
RAEP=$(zenity --list --radiolist --height=410 --title="$NAME $VER - $TODO" --text "In what prefix do you want open your executable?" --hide-header --column "$NAME" --column "Item" FALSE "Steam" FALSE "Blizzard" FALSE "Origin" FALSE "Uplay" FALSE "Teamspeak" FALSE "Clone Hero" FALSE "Drakensang Online" FALSE "Anarchy Online" FALSE "itch" FALSE "GOG Galaxy" FALSE "League of Legends" FALSE "Wargaming Game Center" FALSE "Growtopia" FALSE "Custom Prefix")
EXECUTABLE="$(zenity --file-selection --title="Choose your executable")"
	
if [[ $RAEP == *"Steam"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $LNCH == *"Blizzard"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Origin"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Uplay"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Teamspeak"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Clone Hero"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Drakensang Online"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Anarchy Online"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"itch"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"GOG Galaxy"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"League of Legends"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Wargaming Game Center"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Growtopia"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$RAEP wine "$EXECUTABLE"
fi

if [[ $RAEP == *"Custom Prefix"* ]]; then
cd "/home/$USER/.local/share/$NAME/Custom Prefixes"
FOLDERS=$(ls -a)
PREFIXNAME=$(zenity --list --title="Select a custom prefix" --height=260 --width=300 --column="What prefix?" $FOLDERS)
WINEPREFIX="/home/$USER/.local/share/$NAME/Custom Prefixes/$PREFIXNAME" wine "$EXECUTABLE"
fi
fi

if [[ $TODO == *"Update"* ]]; then
UPDE=$(zenity --list --radiolist --height=200 --width 300 --title="$NAME $VER - $TODO" --text "What do you want to update?" --hide-header --column "$NAME" --column "Item" FALSE "Teamspeak" FALSE "Growtopia" FALSE "Custom Prefix executable" FALSE "Homura to the latest version")

if [[ $UPDE == *"Teamspeak"* ]]; then
WINEPREFIX=/home/$USER/.local/share/$NAME/Programs/$UPDE wine "/home/$USER/.local/share/$NAME/Programs/$UPDE/TeamSpeak 3 Client/update.exe"
kill ts3client_win32.exe
fi

if [[ $UPDE == *"Growtopia"* ]]; then
cd /home/$USER/.local/share/$NAME/Games/$UPDE
curl -L -o "Growtopia-Installer.exe" "https://growtopiagame.com/Growtopia-Installer.exe" 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\\:\2/' | zenity --progress --text "Downloading $UPDE" --title "$NAME $VER $TODO $INST"
echo -e "\e[40;38;5;82mStarting installer\e[30;48;5;82m\e[0m"
WINEPREFIX=/home/$USER/.local/share/$NAME/Games/$UPDE wine /home/$USER/.local/share/$NAME/Games/$UPDE/Growtopia-Installer.exe
rm /home/$USER/.local/share/$NAME/Games/$UPDE/Growtopia-Installer.exe
fi

if [[ $UPDE == *"Custom Prefix executable"* ]]; then
cd "/home/$USER/.local/share/$NAME/Custom Prefixes"
FOLDERS=$(ls -a)
PREFIXNAME=$(zenity --list --title="$NAME $VER - Select a custom prefix" --height=260 --width=300 --column="What prefix?" $FOLDERS)
EXECUTABLE="$(zenity --file-selection --title="Choose your executable")"
ENV=$(zenity --title="Environment variable" --text "Do you need an environment variable for your executable? (for example DXVK_HUD=1) if not leave it blank." --entry --width=260)
SPM=$(zenity --title="Environment variable" --text "Do you need an startparameter for your executable? (for example -console) if not leave it blank." --entry --width=260) 
cd $PREFIXNAME
rm start.sh
echo "$ENV WINEPREFIX='/home/$USER/.local/share/$NAME/Custom Prefixes/$PREFIXNAME' wine '$EXECUTABLE' $SPM" >> start.sh
fi

if [[ $UPDE == *"Homura to the latest version"* ]]; then
cd /home/$USER/.local/share/$NAME
curl -O https://raw.githubusercontent.com/Alexander88207/Homura/master/VER
RELVER=$(cat VER)
if [ $VER = $RELVER ]
        then
                notify-send "Nice, no new available update!"
        else
cd /home/$USER/.local/share/$NAME
curl -O -L https://github.com/Alexander88207/$NAME/archive/$RELVER.tar.gz
tar -xf $RELVER.tar.gz
rm /home/$USER/.local/share/$NAME/$NAME.sh
mv /home/$USER/.local/share/$NAME/$NAME-$RELVER/$NAME.sh /home/$USER/.local/share/$NAME/$NAME.sh
rm /home/$USER/.local/share/$NAME/$RELVER.tar.gz
rm -d -r /home/$USER/.local/share/$NAME/$NAME-$RELVER
rm VER
notify-send "Homura have been updated sucessfully to $RELVER"
fi
fi
fi

if [[ $TODO == *"Open Homura Folder"* ]]; then
xdg-open /home/$USER/.local/share/$NAME
fi

if [[ $TODO == *"About"* ]]; then
zenity --info --width=350 --title="$NAME $VER - About" --text="Inspired by lutris.
Homura is a Windows Games Launcher for FreeBSD and is licensed under the BSD 2-Clause License.
Copyright (c) 2019, Alexander Vereeken
All rights reserved."
fi

if [[ $TODO == *"Exit"* ]]; then
notify-send "Thanks for using $NAME and have a great day!"
exit
fi
notify-send Done!
bash /home/$USER/.local/share/$NAME/$NAME.sh
