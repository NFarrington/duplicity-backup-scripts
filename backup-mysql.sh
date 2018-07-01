#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/includes/config-mysql.sh

# Clear the old log file
cat /dev/null > "$CURRENTLOGFILE"

trace () {
    stamp=`date +%Y-%m-%d_%H:%M:%S`
    echo "$stamp: $*" >> "$CURRENTLOGFILE"
}

#===========

trace "Starting SQL backup: $(date +"%y%m%d%H%M")"

DATABASES=`mysql -u$MYSQL_USER -p$MYSQL_PASS -Be 'SHOW DATABASES;' | grep -Ev "(Database|information_schema|performance_schema|phpmyadmin)"`
for DB in $DATABASES
do
    trace "Processing: ${DB}"
    FILE="${MYSQL_DEST}/my-${DB}.sql"
    mysqldump -u$MYSQL_USER -p$MYSQL_PASS --single-transaction --quick --lock-tables=false $DB > $FILE
done

trace "SQL backup finished"

#============

is_running=$(ps -ef | grep duplicity | grep python | wc -l)

if [ ! -d /var/log/duplicity ]; then
    mkdir -p /var/log/duplicity
fi

if [ $is_running -eq 0 ]; then

    trace "Beginning backup"

    duplicity \
        --full-if-older-than 2D \
        --encrypt-key=${GPG_ENCRYPT_KEY} \
        --sign-key=${GPG_SIGN_KEY} \
        "$MYSQL_DEST" "$DEST" >> "$CURRENTLOGFILE" 2>&1

    trace "Removing old backups"

    duplicity remove-all-inc-of-but-n-full 1 "$DEST" \
        --force \
        --encrypt-key="$GPG_ENCRYPT_KEY" \
        --sign-key="$GPG_SIGN_KEY" >> "$CURRENTLOGFILE" 2>&1

    duplicity remove-older-than "$REMOVE_OLDER_THAN" "$DEST" \
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
