# enable multilib in pacman.conf if x86_64 present
enable_pacman_multilib()
{
    path="$1"

    if [ "$path" = 'chroot' ]
    then
        path="$CHROOT"
    else
        path=""
    fi

    title 'Pacman Setup > Multilib'

    if [ "$(uname -m)" = "x86_64" ]
    then
        woutput '[+] Enabling multilib support'
        printf "\n\n"
        if grep -q "#\[multilib\]" "$path/etc/pacman.conf"
        then
            # it exists but commented
            sed -i '/\[multilib\]/{ s/^#//; n; s/^#//; }' "$path/etc/pacman.conf"
        elif ! grep -q "\[multilib\]" "$path/etc/pacman.conf"
        then
            # it does not exist at all
            printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" \
            >> "$path/etc/pacman.conf"
        fi
    fi

    return $SUCCESS
}


# enable color mode in pacman.conf
enable_pacman_color()
{
  path="$1"

  if [ "$path" = 'chroot' ]
  then
    path="$CHROOT"
  else
    path=""
  fi

  title 'Pacman Setup > Color'

  wprintf '[+] Enabling color mode'
  printf "\n\n"

  sed -i 's/^#Color/Color/' "$path/etc/pacman.conf"

  return $SUCCESS
}


# enable misc options in pacman.conf
enable_pacman_misc()
{
  path="$1"

  if [ "$path" = 'chroot' ]
  then
    path="$CHROOT"
  else
    path=""
  fi

  title 'Pacman Setup > Misc Options'

  wprintf '[+] Enabling DisableDownloadTimeout'
  printf "\n\n"
  sed -i '37a DisableDownloadTimeout' "$path/etc/pacman.conf"

  # put here more misc options if necessary

  return $SUCCESS
}


# update pacman package database
update_pkg_database()
{
  title 'Pacman Setup > Package Database'

  wprintf '[+] Updating pacman database'
  printf "\n\n"

  pacman -Syy --noconfirm > $VERBOSE 2>&1

  return $SUCCESS
}


# update pacman.conf and database
update_pacman()
{
  enable_pacman_multilib
  sleep_clear 1

  enable_pacman_color
  sleep_clear 1

  enable_pacman_misc
  sleep_clear 1

  update_pkg_database
  sleep_clear 1

  return $SUCCESS
}
