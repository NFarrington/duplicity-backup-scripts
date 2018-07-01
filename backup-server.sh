#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/includes/config-server.sh

is_running=$(ps -ef | grep duplicity | grep python | wc -l)

if [ ! -d /var/log/duplicity ]; then
    mkdir -p /var/log/duplicity
fi

if [ $is_running -eq 0 ]; then
    # Clear the old log file
    cat /dev/null > "$CURRENTLOGFILE"

    trace () {
        stamp=`date +%Y-%m-%d_%H:%M:%S`
        echo "$stamp: $*" >> "$CURRENTLOGFILE"
    }

    trace "Beginning backup"

    duplicity \
        --full-if-older-than 7D \
        --encrypt-key=${GPG_ENCRYPT_KEY} \
        --sign-key=${GPG_SIGN_KEY} \
        --exclude=/dev \
        --exclude=/lost+found \
        --exclude=/media \
        --exclude=/mnt \
        --exclude=/proc \
        --exclude=/run \
        --exclude=/sys \
        --exclude=/tmp \
        --exclude=/var/tmp \
        --exclude=/srv/db \
        --exclude=/var/backups \
        --exclude=/var/lib/docker/overlay2 \
        / "$DEST" >> "$CURRENTLOGFILE" 2>&1

    trace "Removing old backups"

    duplicity remove-older-than "$REMOVE_OLDER_THAN" --force "$DEST" \
        --force \
        --encrypt-key="$GPG_ENCRYPT_KEY" \
        --sign-key="$GPG_SIGN_KEY" >> "$CURRENTLOGFILE" 2>&1

    trace "Backup complete"
    trace "------------------------------------"

    # Send the current log file by email if there are errors
    BACKUPSTATUS=`cat "$CURRENTLOGFILE" | grep Errors | awk '{ print $2 }'`
    if [ "$BACKUPSTATUS" != "0" ]; then
        cat "$CURRENTLOGFILE" | mail -s "$MAILSUBJ" "$MAILADDR"
    fi

    # Append the current log file to the main log file
    cat "$CURRENTLOGFILE" >> "$LOGFILE"
fi

. "$DIR"/includes/cleanup.sh
