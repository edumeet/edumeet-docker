#!/bin/sh 

echo "Container starting up..." 
echo "----------------------------" 
set -e 

cd ${BASEDIR}/${MM}/server
node ${BASEDIR}/${MM}/server/server.js

exec "$@"
