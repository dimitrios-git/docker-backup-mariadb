#!/bin/bash

set -euxo pipefail

if [ -n ${CRONTAB+x} ]; then
    echo "$CRONTAB" | crontab -
else
    echo "Use CRONTAB to schedule your database dumps."
fi

exec "$@"
