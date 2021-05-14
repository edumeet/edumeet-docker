#!/bin/sh 

echo "Container starting up..." 
set -e 

cd ${BASEDIR}/${EDUMEET}/server
node ${BASEDIR}/${EDUMEET}/server/dist/server.js

exec "$@"
