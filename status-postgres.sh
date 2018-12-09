#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/includes/config-postgres.sh

duplicity collection-status "$DEST"
EXIT=$?

. "$DIR"/includes/cleanup.sh

exit $EXIT
