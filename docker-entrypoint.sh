#!/bin/bash 
echo "Container starting up..." 
set -e 
cd /opt/edumeet-room-server/
#node /opt/edumeet-room-server/dist/server.js
yarn start
exec "$@"
