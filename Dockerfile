FROM node:lts-alpine AS mm-builder

# Args
ARG BASEDIR=/opt
ARG MM=multiparty-meeting
ARG NODE_ENV=production
ARG SERVER_DEBUG=''

WORKDIR ${BASEDIR}

RUN apk add --no-cache git

#checkout code
RUN git clone https://github.com/havfo/${MM}.git

#install app dep
WORKDIR ${BASEDIR}/${MM}/app
RUN yarn install --production=false --network-timeout 100000

# set app in producion mode/minified/.
ENV NODE_ENV ${NODE_ENV}

# Workaround for the next yarn run build => rm -rf public dir even if it does not exists.
# TODO: Fix it smarter
RUN mkdir -p ${BASEDIR}/${MM}/server/public

# package web app
RUN yarn run build


#install server dep
WORKDIR ${BASEDIR}/${MM}/server

RUN apk add --no-cache git build-base python linux-headers

RUN yarn install --production=true --network-timeout 100000


FROM node:lts-alpine

# Args
ARG BASEDIR=/opt
ARG MM=multiparty-meeting
ARG NODE_ENV=production
ARG SERVER_DEBUG=''

WORKDIR ${BASEDIR}


COPY --from=mm-builder ${BASEDIR}/${MM}/server ${BASEDIR}/${MM}/server



# Web PORTS
EXPOSE 80 443 
EXPOSE 40000-49999/udp


## run server 
ENV DEBUG ${SERVER_DEBUG}

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
