#/bin/bash
source .env
docker run \
	-v ${PWD}/config/app-config.js:${BASEDIR}/${MM}/app/config.js \
	-v ${PWD}/config/server-config.js:${BASEDIR}/${MM}/server/config.js \
	-v ${PWD}/cert/privkey.pem:${BASEDIR}/${MM}/server/certs/privkey.pem \
        -v ${PWD}/cert/cert.pem:${BASEDIR}/${MM}/server/certs/cert.pem \
	-e BASEDIR=${BASEDIR} -e MM=${MM} \
	--network host \
	--name mm \
	--detach \
      misi/mm

docker cp style/logo-white.jpg mm:${BASEDIR}/${MM}/app/resources/images/logo.svg
docker cp style/logo-transparent.png mm:${BASEDIR}/${MM}/app/resources/images/logo-transparent.png
docker exec -t mm sed -r -i -e "s|<img src='.+'>|<img src='/resources/images/logo-transparent.png'>|g" chooseRoom.html

