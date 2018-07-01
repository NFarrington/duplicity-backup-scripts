#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/includes/config-server.sh

duplicity collection-status "$DEST"

. "$DIR"/includes/cleanup.sh
