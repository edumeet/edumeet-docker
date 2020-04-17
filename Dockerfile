FROM node:13-alpine AS mm-builder

# Args
ARG BASEDIR=/opt
ARG MM=multiparty-meeting
ARG NODE_ENV=production
ARG SERVER_DEBUG=''
ARG BRANCH=develop
ARG REACT_APP_DEBUG=''

WORKDIR ${BASEDIR}

RUN apk add --no-cache git bash

#checkout code
RUN git clone --single-branch --branch ${BRANCH} https://github.com/havfo/${MM}.git

#install app dep
WORKDIR ${BASEDIR}/${MM}/app

#RUN yarn install --production=false --network-timeout 100000
RUN npm install

# set app in producion mode/minified/.
ENV NODE_ENV ${NODE_ENV}

# Workaround for the next yarn run build => rm -rf public dir even if it does not exists.
# TODO: Fix it smarter
RUN mkdir -p ${BASEDIR}/${MM}/server/public

ENV REACT_APP_DEBUG=${REACT_APP_DEBUG}

# package web app
#RUN REACT_APP_DEBUG=* yarn run build
# package web app
RUN npm run build


#install server dep
WORKDIR ${BASEDIR}/${MM}/server

RUN apk add --no-cache git build-base python linux-headers

#RUN yarn install --production=true --network-timeout 100000
RUN npm install


FROM node:13-alpine

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
