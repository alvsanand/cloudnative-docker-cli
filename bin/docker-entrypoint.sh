#!/bin/bash

set -e

if [[ -z "$(getent group $(id -g))" ]]; then
    sudo groupmod -g $(id -g) cloudnative-docker-cli
fi

exec "$@"