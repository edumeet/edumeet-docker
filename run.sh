#/bin/bash
source .env
docker run \
	-v ${PWD}/configs/app:${BASEDIR}/${EDUMEET}/server/public/config \
	-v ${PWD}/configs/server:${BASEDIR}/${EDUMEET}/server/config \
	-v ${PWD}/certs:${BASEDIR}/${EDUMEET}/server/certs \
	-v ${PWD}/images:${BASEDIR}/${EDUMEET}/server/public/images \
    -v ${PWD}/privacy:${BASEDIR}/${EDUMEET}/server/public/static/privacy \
	-e BASEDIR=${BASEDIR} -e EDUMEET=${EDUMEET} \
	--network host \
	--restart unless-stopped \
	--name edumeet \
	--detach \
      misi/edumeet:${TAG}
