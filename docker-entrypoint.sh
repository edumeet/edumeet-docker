#!/bin/bash 

echo "Container starting up..." 
set -e 

cd ${BASEDIR}/${EDUMEET}/server
if [[ ! -e ${BASEDIR}/${EDUMEET}/server/dist/config/config.js ]] || [[ $(head -1 ${BASEDIR}/${EDUMEET}/server/config/config.js) != $(head -1 ${BASEDIR}/${EDUMEET}/server/dist/config/config.js) ]] 
  then
      echo "Rebuilding configuration..."
      npm run build
fi

npm start
#node ${BASEDIR}/${EDUMEET}/server/server.js

exec "$@"
