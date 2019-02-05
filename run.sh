#/bin/bash
source .env
docker run \
	-v ${PWD}/configs/app:${BASEDIR}/${MM}/app/config \
	-v ${PWD}/configs/server:${BASEDIR}/${MM}/server/config \
	-v ${PWD}/certs:${BASEDIR}/${MM}/server/certs \
	-e BASEDIR=${BASEDIR} -e MM=${MM} \
	--network host \
	--detach \
      misi/mm
