#!/bin/bash

if [ "${TEMPLATE_REPLACE}" = "true" ]; then
    envsubst < /app/config/config.json.template > /app/edumeet-room-server/config/config.json
fi

#cd /app/edumeet-room-server 
#DEBUG=${SERVER_DEBUG} yarn run prodstart $0 $@ &
nginx 

echo "Starting MEDIA-NODE"
cd /app/edumeet-media-node 
DEBUG=${MN_DEBUG} yarn run prodstart $0 $@ &
echo "Starting ROOM-SERVER"
cd /app/edumeet-room-server 
DEBUG=${SERVER_DEBUG} yarn run prodstart
