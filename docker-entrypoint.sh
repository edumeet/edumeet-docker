#!/bin/bash 

echo "Container starting up..." 
set -e 

# Server side app also has to be build before deployment.
# Configuration is rebuild if first line is changed.
# Any kind of unique comment is acceptable e.g. //YYYYMMDDxx 
# NOTE: THIS IS TEMPORARY WORKAROUND

cd ${BASEDIR}/${EDUMEET}/server


node ${BASEDIR}/${EDUMEET}/server/dist/server.js

exec "$@"
