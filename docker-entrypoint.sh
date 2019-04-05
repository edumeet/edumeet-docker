#!/bin/sh 

echo "Container starting up..." 
set -e 

cd ${BASEDIR}/${MM}/server
node ${BASEDIR}/${MM}/server/server.js

exec "$@"
