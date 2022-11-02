#!/bin/bash 
echo "Container starting up..." 
set -e 
node /opt/edumeet/server/dist/server.js
#cd /opt/edumeet/server/dist/ && yarn start
exec "$@"
