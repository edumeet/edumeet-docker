#/bin/bash
source .env
docker run \
	-v ${PWD}/configs/app:${BASEDIR}/${MM}/server/public/config \
	-v ${PWD}/configs/server:${BASEDIR}/${MM}/server/config \
	-v ${PWD}/certs:${BASEDIR}/${MM}/server/certs \
	-v ${PWD}/images:${BASEDIR}/${MM}/server/public/images \
	-e BASEDIR=${BASEDIR} -e MM=${MM} \
	--network host \
	--restart unless-stopped \
	--name mm \
	--detach \
      misi/mm:oidc
