#/bin/bash
source .env
docker run \
	-v ${PWD}/config/app-config.js:${BASEDIR}/${MM}/app/config.js \
	-v ${PWD}/config/server-config.js:${BASEDIR}/${MM}/server/config.js \
	-v ${PWD}/cert/privkey.pem:${BASEDIR}/${MM}/server/certs/privkey.pem \
        -v ${PWD}/cert/cert.pem:${BASEDIR}/${MM}/server/certs/cert.pem \
	-e BASEDIR=${BASEDIR} -e MM=${MM} \
	--network host \
	--detach \
      misi/mm
