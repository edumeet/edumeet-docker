#!/bin/bash 

echo "Container starting up..." 
set -e 

# Server side app also has to be build before deployment.
# Configuration is rebuild if first line is changed.
# Any kind of unique comment is acceptable e.g. //YYYYMMDDxx 
# NOTE: THIS IS TEMPORARY WORKAROUND

cd ${BASEDIR}/${EDUMEET}/server

if [[ ! -e ${BASEDIR}/${EDUMEET}/server/dist/config/config.js ]] || [[ $(head -1 ${BASEDIR}/${EDUMEET}/server/config/config.js) != $(head -1 ${BASEDIR}/${EDUMEET}/server/dist/config/config.js) ]] 
  then
      echo "Rebuilding configuration..."
      npm run build
fi

node ${BASEDIR}/${EDUMEET}/server/dist/server.js

exec "$@"
