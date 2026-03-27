#!/bin/bash

if [ "${TEMPLATE_REPLACE}" = "true" ]; then
    envsubst < /usr/src/app/config/config.json.template > /usr/src/app/config/config.json
fi

DEBUG=${SERVER_DEBUG} LOG_LEVEL=${SERVER_DEBUG_LEVEL} yarn run prodstart $0 $@
