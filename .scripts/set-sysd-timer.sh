#!/bin/bash
#!!! systemd timer functionality for wp-script,
#     to be made into universal tool.

# TIMER VARIABLES
#=================

#SELF_REF_NAME='wp-script'
EXEC_PATH=$(readlink -f "$0")
EXEC_PARAMS='change q'
SELF_REF_NAME="$(basename $EXEC_PATH)"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SELF_REF_NAME.service"
TIMER_FILE="$SELF_REF_NAME.timer"
ENV_CONF_DIR="$HOME/.config/environment.d"
ENV_CONF_FILE="environment-vars.conf"
ENV_VARS='DISPLAY'

ONCALENDAR_DFLT='hourly' # OnCalendar format
# OnCalendar
#-----------
# General format: DayOfWeek Year-Month-Day Hour:Minute:Second
#         list:  val1,val3,val5
#         range: val1..val5
# example: Mon,Tue *-*-01..04 12:00:00
#          the first four days of each month at 12:00 PM, but only if that day is a Monday or a Tuesday.

#      minutely → *-*-* *:*:00
#        hourly → *-*-* *:00:00
#         daily → *-*-* 00:00:00
#       monthly → *-*-01 00:00:00
#        weekly → Mon *-*-* 00:00:00
#        yearly → *-01-01 00:00:00
#     quarterly → *-01,04,07,10-01 00:00:00
#  semiannually → *-01,07-01 00:00:00


WP_QUIET='0'
wp_massage () {

    if [[ $WP_QUIET = '0' ]]
    then
        nc="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"


        local clnt sprt sprt_c c_sprt lgp sgp

        case $1 in
            1 )
                sprt_c=$green ;;
           -1 )
                sprt_c=$red ;;
            0 )
                sprt_c=$yellow ;;
            esac
        sprt='==>' # The separator
        c_sprt="$sprt_c$sprt$nc"    

        clnt="${FUNCNAME[1]}" # The client function name.

        # The spase gap starting every additional massage line.
        lgp=$((${#clnt} + ${#sprt} + 2))
        sgp=''
        while [[ ${#sgp} -lt $lgp ]]
            do
                sgp=" $sgp"
            done

        # A multiline sed replacement trick.
        # The sed reads the whole massage (file), then the replacement.
        echo -e "$clnt" "$c_sprt" "$2" | sed -e ':a' -e 'N' -e '$!ba' -e "s/\n/\n$sgp/g"
    fi
}

# TIMER FANCTIONS
#=================

timer-create-files () {
  if [ ! -d $SERVICE_DIR ]
    then
      #massage
      wp_massage 0 "The directory for local systemd services does not exist.\nCreating '$SERVICE_DIR'..."
      mkdir -p $SERVICE_DIR
  fi

  #massage
  wp_massage 0 "Creating '$SERVICE_FILE' file. ...\n(Exec line: 'ExecStart=$EXEC_PATH $EXEC_PARAMS')"
  printf '%s\n' \
    "[Unit]" \
    "Description=Changes wallpaper with  $SELF_REF_NAME script." \
    "Wants=$SELF_REF_NAME.timer" \
    "" \
    "[Service]" \
    "Type=oneshot" \
    "ExecStart=$EXEC_PATH $EXEC_PARAMS" \
    "" \
    "[Install]" \
    "WantedBy=default.target" \
    > $SERVICE_DIR/$SERVICE_FILE

  #massage
  wp_massage 0 "Creating '$TIMER_FILE' file.\n(OnCalendar=$ONCALENDAR_DFLT) ..."
  printf '%s\n' \
    "[Unit]" \
    "Description=Timer for  $SELF_REF_NAME service." \
    "" \
    "[Timer]" \
    "OnCalendar=$ONCALENDAR_DFLT" \
    "RandomizedDelaySec=60" \
    "" \
    "[Install]" \
    "WantedBy=timers.target" \
    > $SERVICE_DIR/$TIMER_FILE

  if [ ! -d $ENV_CONF_DIR ]
    then
      #massage
      wp_massage 0 "The directory for local systemd environment configs, does not exist.\nCreating '$ENV_CONF_DIR'..."
      mkdir -p $ENV_CONF_DIR
  fi
 [ -f "$ENV_CONF_DIR/$ENV_CONF_FILE" ] \
   && echo '' >  "$ENV_CONF_DIR/$ENV_CONF_FILE"
  local env_var_line
  for env_var in $ENV_VARS
    do
      env_var_line=$(eval echo "$env_var=\${$env_var}")
      #massage
      wp_massage 0 "Adding '$env_var_line line, to '$ENV_CONF_FILE' file. ..."
      echo "$env_var_line" >> "$ENV_CONF_DIR/$ENV_CONF_FILE"
  done
}


timer-files-exist () {
  [ -f $SERVICE_DIR/$SERVICE_FILE ] \
    && [ -f $SERVICE_DIR/$TIMER_FILE ]
}

timer-set-OnCalendar () {
  local timer_val
  timer_val=$1
  sed -i "/OnCalendar=/ s/^.*$/OnCalendar=$timer_val/" $SERVICE_DIR/$TIMER_FILE
  systemctl --user daemon-reload
}

timer-set-env-vars () {

  local env_var sysd_var sysd_var_line bash_var export_var daemon_reload

  daemon_reload=false

  # massage
  wp_massage 0 "Checking local systemd envitonment variables ..."
  for env_var in $ENV_VARS
  do
    export_var=false
    eval bash_var=\${$env_var}
    sysd_var_line=$( systemctl --user show-environment | grep "$env_var" )
    if [ ! -z $sysd_var_line ]
      then
        sysd_var="${sysd_var_line#*=}"
        if [ "$sysd_var" == "$bash_var" ]
          then
            # massage
            wp_massage 1 "'$env_var' var is valid."
          else
            # massage
            wp_massage -1 "'$env_var' var is not valid."
            export_var=true
        fi
      else
        # massage
        wp_massage -1 "'$env_var' var is not found."
        export_var=true
    fi
    if $export_var
      then
        # massage
        wp_massage 0 "Importing '$env_var' var, from bash environment ... "
        systemctl --user import-environment "$env_var"

        if command -v dbus-update-activation-environment >/dev/null 2>&1
          then
            dbus-update-activation-environment "$env_var"
        fi
      $daemon_reload || daemon_reload=true
    fi
  done

  if $daemon_reload
    then
       massage
      wp_massage 0 "Reloading the service daemon. ..."
      systemctl --user daemon-reload
  fi
}

timer-service-isenabled () {
  systemctl --user status $SERVICE_FILE 2> /dev/null \
      | grep 'enabled;' > /dev/null 2>&1
}

timer-isenabled () {
  systemctl --user status $TIMER_FILE 2> /dev/null  \
      | grep 'enabled;' > /dev/null 2>&1
}

timer-isactive () {
  systemctl --user list-timers \
    | grep " $TIMER_FILE " > /dev/null 2>&1
}

timer-start () {
  timer-set-env-vars
  if ! timer-isactive
    then
      # massage
      wp_massage 0 "The timer is not active.\nStarting the service..."
      if ! timer-service-isenabled
        then
        # massage
        wp_massage 0 "Enabling $SERVICE_FILE ..."
        systemctl --user enable $SERVICE_FILE
      fi
      if ! timer-isenabled
        then
          # massage
          wp_massage 0 "Enabling $TIMER_FILE ..."
          systemctl --user enable $TIMER_FILE
      fi
      # massage
      wp_massage 0 "Starting $TIMER_FILE ..."
      systemctl --user start $TIMER_FILE
  fi
}

timer-stop () {
  if timer-isactive
    then
      # massage
      wp_massage 0 "Stopping $TIMER_FILE ..."
      systemctl --user stop $TIMER_FILE
    else
      # massage
      wp_massage 0 "$TIMER_FILE is not active ..."
  fi
  if timer-isenabled
    then
      # massage
      wp_massage 0 "Disabling $TIMER_FILE ..."
      systemctl --user disable $TIMER_FILE
    else
  # massage
  wp_massage 0 "$TIMER_FILE is disabled ..."
  fi
}

timer-status () {
  local timer_val timer_status
  if timer-isactive
    then
      timer_val=$(sed -n '/OnCalendar/ s/^.*=\(.*\)$/\1/p' $SERVICE_DIR/$TIMER_FILE )
      timer_next=$(systemctl --user status $TIMER_FILE \
        | grep Trigger: \
        | sed 's/^.*Trigger://' )
      timer_status="ON ($timer_val). Next: $timer_next"
    else
      timer_status="OFF"
  fi
  echo "TIMER: $timer_status"
}

# TIMER COMMANDS
#=================

wp-cmd-set-timer () {
  wp-cmd-timerOn "$1"
}

wp-cmd-timerOn () {
  # massage
  wp_massage 0 "Checking the timer service config files. ..."
  ! timer-files-exist \
    && timer-create-files
  if [ ! -z "$1" ]
    then
      local oncalendar
      oncalendar="$1"
      # massage
      wp_massage 0 "Setting up 'OnCalenar=$oncalendar' in $TIMER_FILE file ..."
      timer-set-OnCalendar "$oncalendar"
  fi
  timer-start
  timer-status
}

wp-cmd-timerOff () {
  timer-stop
  timer-status
}

# ACTION
#========

wp-dispatcher () {

  local wp_cmd oncalendar

  wp_cmd="$1"

  [[ "$wp_cmd" = 'set-timer' ]] \
    && wp_cmd='set_timer'

  if [[ "$wp_cmd" =~ ^timer=.*$ ]]
    then
      oncalendar="${1#timer=}"
      systemd-analyze calendar "$oncalendar" > /dev/null 2>&1 \
        && wp_cmd='set-timer' \
        || wp_massage -1 "The timer value '$oncalendar' is not an 'OnCalendar' timestamp." \

    fi

        case $wp_cmd in
            'set-timer' )
                wp-cmd-set-timer "$oncalendar"
                ;;
            'timerOn' )
                wp-cmd-timerOn
                ;;
            'timerOff' )
                wp-cmd-timerOff
                ;;
            * )
                wp_massage -1  "Unknown command '$wp_cmd'" ;;
            esac
}

wp-dispatcher "$1"
