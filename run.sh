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
      misi/mm:dev
