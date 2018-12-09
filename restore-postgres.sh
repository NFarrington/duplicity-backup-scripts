#!/bin/bash

# restore.sh <date> <file> <restore-to>

if [ $# -lt 3 ]; then echo "Usage $0 <date> <file> <restore-to>"; exit; fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/includes/config-postgres.sh

duplicity \
    --restore-time "$1" \
    --file-to-restore "$2" \
    "$DEST" "$3"
EXIT=$?

. "$DIR"/includes/cleanup.sh

exit $EXIT
