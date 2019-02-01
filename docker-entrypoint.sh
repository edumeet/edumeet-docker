#!/bin/sh 

echo "Container starting up..." 
set -e 

#run dist-watch
cd ${BASEDIR}/${MM}/app
nohup sh -c "gulp dist-watch" &

cd ${BASEDIR}/${MM}/server
node ${BASEDIR}/${MM}/server/server.js

exec "$@"
