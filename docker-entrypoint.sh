#!/bin/bash 
echo "Container starting up..." 
set -e 
node /opt/edumeet/dist/server.js
#yarn start
exec "$@"
