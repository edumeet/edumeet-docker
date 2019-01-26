#/bin/bash
source .env
docker run \
	-v ${PWD}/config/server-config.js:${BASEDIR}/${MM}/server/config.js \
	-v ${PWD}/cert/privkey.pem:${BASEDIR}/${MM}/server/certs/privkey.pem \
        -v ${PWD}/cert/cert.pem:${BASEDIR}/${MM}/server/certs/cert.pem \
	-e BASEDIR=${BASEDIR} -e MM=${MM} \
	--network host \
	--name mm \
	--detach \
      misi/mm
docker exec -t mm sed -r -i -e "s|<img src='.+'>|<img src='https://up2university.eu/wp-content/uploads/2017/03/Logo_UP2U_120x120.png'>|g" public/chooseRoom.html

