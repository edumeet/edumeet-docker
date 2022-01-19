FROM node:14-bullseye-slim AS edumeet-builder

# Args
ARG BASEDIR=/opt
ARG EDUMEET=edumeet
ARG NODE_ENV=production
ARG SERVER_DEBUG=''
ARG BRANCH=develop
ARG REACT_APP_DEBUG=''

WORKDIR ${BASEDIR}

RUN apt-get update;apt-get install -y git bash build-essential python openssl libssl-dev pkg-config;apt-get clean

#checkout code
RUN git clone --single-branch --branch ${BRANCH} https://github.com/edumeet/${EDUMEET}.git

#install app dep
WORKDIR ${BASEDIR}/${EDUMEET}/app

RUN yarn install --production=false

# set app in producion mode/minified/.
ENV NODE_ENV ${NODE_ENV}

# Workaround for the next npm run build => rm -rf public dir even if it does not exists.
# TODO: Fix it smarter
RUN mkdir -p ${BASEDIR}/${EDUMEET}/server/public

ENV REACT_APP_DEBUG=${REACT_APP_DEBUG}

# package web app
RUN yarn run build

#install server dep
WORKDIR ${BASEDIR}/${EDUMEET}/server

RUN yarn install --production=false && yarn run build

FROM node:14-bullseye-slim

# Args:
ARG BASEDIR=/opt
ARG EDUMEET=edumeet
ARG NODE_ENV=production
ARG SERVER_DEBUG=''

WORKDIR ${BASEDIR}

COPY --from=edumeet-builder ${BASEDIR}/${EDUMEET}/server ${BASEDIR}/${EDUMEET}/server

RUN apt-get update;apt-get install -y openssl;apt-get clean

# Web PORTS
EXPOSE 80 443 
EXPOSE 40000-49999/udp

## run server 
ENV DEBUG ${SERVER_DEBUG}

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
