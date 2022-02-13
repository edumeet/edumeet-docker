#/bin/bash
source .env
docker run \
	-v ${PWD}/configs/app:${BASEDIR}/${EDUMEET}/server/dist/public/config \
	-v ${PWD}/configs/server:${BASEDIR}/${EDUMEET}/server/dist/config \
	-v ${PWD}/certs:${BASEDIR}/${EDUMEET}/server/certs \
	-v ${PWD}/images:${BASEDIR}/${EDUMEET}/server/dist/public/images \
  -v ${PWD}/privacy:${BASEDIR}/${EDUMEET}/server/dist/public/static/privacy \
  -v ${PWD}/.well-known:${BASEDIR}/${EDUMEET}/server/dist/public/.well-known
	-e BASEDIR=${BASEDIR} -e EDUMEET=${EDUMEET} \
	--network host \
	--restart unless-stopped \
	--name edumeet \
	--detach \
      edumeet/edumeet:${TAG}
