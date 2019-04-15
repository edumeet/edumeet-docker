#/bin/bash
source .env
docker run \
	-v ${PWD}/configs/app:${BASEDIR}/${MM}/app/config \
	-v ${PWD}/configs/server:${BASEDIR}/${MM}/server/config \
	-v ${PWD}/certs:${BASEDIR}/${MM}/server/certs \
	-v ${PWD}/logo/logo.svg:${BASEDIR}/${MM}/app/resources/images/logo.svg \
	-e BASEDIR=${BASEDIR} -e MM=${MM} \
	--network host \
	--restart unless-stopped \
	--name mm \
	--detach \
      misi/mm

docker cp style/logo-white.jpg mm:${BASEDIR}/${MM}/app/resources/images/logo.svg
docker cp style/logo-white.jpg mm:${BASEDIR}/${MM}/app/resources/images/logo.jpg
docker exec -t mm sed -r -i -e "s|<img src='.+'>|<img src='/resources/images/logo.jpg'>|g" chooseRoom.html

