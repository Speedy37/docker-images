#!/bin/bash

# check if stdout is a terminal...
if test -t 1; then
    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
        input="$green"
        gen="$cyan"
        imp="$red"
    fi
fi

image="private/duplicity"
volsize=256
full_if_older_than=1M
backup_args=""
docker_compose=$(which docker-compose)
docker=$(which docker)
systemd_files=/etc/systemd/system

echo "Creating systemd service for docker-compose service"
echo -e "Path to docker-compose: $gen$docker_compose$normal"
echo -e "Path to docker: $gen$docker$normal"
echo -e "Path to systemd files: $gen$systemd_files$normal"
echo -e "Path to systemctl: $gen$(which systemctl)$normal"
echo -e "Name of the docker duplicity image: $gen$image$normal"
echo ""

next="mkservice"
while true; do
  echo "Now you can"
  echo "  mkservice Create a service for your docker-compose.yml"
  echo "  mkbackup  Create a backup container"
  echo "  mktimer   Schedule a backup container start"
  echo "  restore   Restore a backup"
  echo "  quit      Quit this program"
  echo ""
  read -e -p "What do you want to do? $input" -i "$next" todo; echo -n -e "$normal"
  if [ "$todo" = "mkservice" ]; then

    read -e -p "Path to the docker-compose folder: $input" -i "$path" path; echo -n -e "$normal"
    if [ ! -f "$path/docker-compose.yml" ]; then echo "File $path/docker-compose.yml doesn't exists"; exit 1; fi
    if [ "$name" = "" ]; then name=$(basename $path); fi
    read -e -p "Name of the service: $input" -i "$name" name; echo -n -e "$normal"
    if [ "$name" = "" ]; then echo "Service name cannot be empty"; exit 1; fi

    service="[Unit]
Description=$name
Requires=docker.service
After=docker.service

[Service]
Restart=always
WorkingDirectory=$path
ExecStart=$docker_compose up
ExecStop=$docker-compose stop -t 2

[Install]
WantedBy=multi-user.target"

    echo "Generated systemd service file:"
    echo -e "$gen$service$normal"
    echo -e "will be written to $gen$systemd_files/$name.service$normal"
    read -e -p "Do you want to create the systemd service ? $input" -i "y" question; echo -n -e "$normal"
    if [ "$question" == "y" ]; then
      echo "$service" > "$systemd_files/$name.service"
      echo -e "Service installed at $systemd_files/$name.service"
      systemctl daemon-reload
      systemctl enable $name
      systemctl start $name
      echo "${green}Systemd service created, enabled and started$normal"
      next="mkbackup"
    fi
  fi # mkservice

  if [ "$todo" = "mkbackup" ]; then

    read -e -p "Path to backup: $input" -i "$path" path; echo -n -e "$normal"

    read -e -p "Passphrase for the backup: $input" passphrase; echo -n -e "$normal"
    if [ "$passphrase" = "" ]; then echo "The passphrase cannot be empty"; exit 1; fi

    if [ "$name" = "" ]; then name=$(basename $path); fi
    if [ "$backup_name" = "" ]; then backup_name="$name.backup"; fi
    read -e -p "Name of the backup container: $input" -i "$backup_name" backup_name; echo -n -e "$normal"
    if [ "$backup_name" = "" ]; then echo "The backup container name cannot be empty"; exit 1; fi

    read -e -p "Target url of the backup: $input" -i "cf+hubic://$name" target_url; echo -n -e "$normal"
    if [ "$target_url" = "" ]; then echo "Target url cannot be empty"; exit 1; fi

    backup_args=""
    read -e -p "Size of duplicity volume: $input" -i "$volsize" volsize; echo -n -e "$normal"
    backup_args="$backup_args --volsize=$volsize"
    read -e -p "Full backup if older than: $input" -i "$full_if_older_than" full_if_older_than; echo -n -e "$normal"
    backup_args="$backup_args --full-if-older-than $full_if_older_than"
    read -e -p "Perform file uploads asynchronously in the background ? $input" -i "y" question; echo -n -e "$normal"
    if [ "$question" = "y" ]; then backup_args="$backup_args --asynchronous-upload"; fi
    read -e -p "duplicity arguments: $input" -i "$backup_args" backup_args; echo -n -e "$normal"

    backup="$docker run -e PASSPHRASE=${passphrase} -h ${backup_name} --name=${backup_name} -v ${path}:/data:ro \\
      ${image} duplicity ${backup_args} /data \\
      ${target_url}"
    backup_init="$docker run --rm -e PASSPHRASE=${passphrase} -h ${backup_name} --volumes-from=${backup_name} \\
      ${image} duplicity ${backup_args} --allow-source-mismatch /data \\
      ${target_url}"

    echo "Backup container run command:"
    echo -e "$gen$backup$normal"
    read -e -p "Do you want to create the container now ? $input" -i "y" question; echo -n -e "$normal"
    if [ "$question" = "y" ]; then
      echo "Creating the container:$gen"
      bash -c "$backup"
      if [ $? -ne 0 ]; then
        read -e -p "${normal}Container creation failed, do you want to do a one shot backup with --allow-source-mismatch ? $input" -i "y"; echo -n -e "$normal"
        if [ "$question" = "y" ]; then
          echo -n -e "$gen"
          bash -c "$backup_init"
          if [ $? -ne 0 ]; then echo -e "${normal}Container creation failed: $gen$backup_init$normal"; question="n"; fi
        fi
      fi
      echo -n -e "$normal"
      if [ "$question" = "y" ]; then
        echo "Backup container created and first backup done"
        next="mktimer"
      fi
    fi
  fi

  if [ "$todo" = "mktimer" ]; then
    if [ "$backup_name" = "" ]; then
      read -e -p "Name of the backup container: $input" -i "$name.backup" backup_name; echo -n -e "$normal"
      if [ "$backup_name" = "" ]; then echo "The backup container name cannot be empty"; exit 1; fi
    fi
    read -e -p "Name of the timer: $input" -i "$name.backup" timer_name; echo -n -e "$normal"
    if [ "$name" = "" ]; then echo "Timer name cannot be empty"; exit 1; fi

    read -e -p "When do you want the backup to occur ? $input" -i "*-*-* 01:00:00" timer_calendar; echo -n -e "$normal"

    timer="[Unit]
Description=$timer_name backup

[Timer]
OnCalendar=$timer_calendar

[Install]
WantedBy=timers.target"

    service="[Unit]
Description=$timer_name backup
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/docker start -a ${backup_name}"

    echo "Systemd timer definition:"
    echo -e "$gen$timer$normal"
    echo -e "will be written to $gen$systemd_files/$timer_name.timer$normal"
    echo "Systemd service definition:"
    echo -e "$gen$service$normal"
    echo -e "will be written to $gen$systemd_files/$timer_name.service$normal"

    read -e -p "Do you want to create the systemd timer & service ? $input" -i "y" question; echo -n -e "$normal"
    if [ "$question" == "y" ]; then
      echo "$timer" > "$systemd_files/$timer_name.timer"
      echo -e "Timer installed at $systemd_files/$timer_name.timer"
      echo "$service" > "$systemd_files/$timer_name.service"
      echo -e "Backup service installed at $systemd_files/$timer_name.service"
      systemctl daemon-reload
      systemctl start ${timer_name}.timer
      systemctl enable ${timer_name}.timer
      echo "${green}Systemd service & timer created$normal"
      next="quit"
    fi
  fi

  if [ "$todo" = "restore" ]; then
    read -e -p "Path to restore the backup: $input" -i "$restore_path" restore_path; echo -n -e "$normal"
    read -e -p "Passphrase of the backup: $input" passphrase; echo -n -e "$normal"
    if [ "$passphrase" = "" ]; then echo "The passphrase cannot be empty"; exit 1; fi

    read -e -p "Target url of the backup: $input" -i "cf+hubic://$name" target_url; echo -n -e "$normal"
    if [ "$target_url" = "" ]; then echo "Target url cannot be empty"; exit 1; fi

    restore="$docker run --rm -e PASSPHRASE=${passphrase} -v ${restore_path}:/data \\
      ${image} duplicity restore ${target_url} /data"

    echo -e "Restore command: $gen$restore$normal"
    read -e -p "Do you want to restore ? $input" -i "y" question; echo -n -e "$normal"
    if [ "$question" == "y" ]; then
      echo -n -e "$gen"
      bash -c "$restore"
      if [ $? -eq 0 ]; then echo -e "${green}SUCCESS${normal}"; next="quit"; else echo -e "${red}FAILED${normal}"; fi
    fi
  fi

  if [ "$todo" = "quit" ]; then
    exit 0;
  fi

done
