#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
        set -- nodebb "$@"
fi

if [ "$1" = 'nodebb' ] && [ "$2" = 'start' ]; then
        chown -R nodebb .
        su nodebb -c "nodebb setup"
        exec gosu nodebb node loader.js
fi

# allow the container to be started with `--user`
if [ "$1" = 'nodebb' -a "$(id -u)" = '0' ]; then
        chown -R nodebb .
        exec gosu nodebb "$0" "$@"
fi

exec "$@"