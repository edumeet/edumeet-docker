#build edumeet 
FROM node:16-bullseye-slim AS edumeet-builder

# Args
ARG BASEDIR=/opt
ARG EDUMEET=edumeet
ARG NODE_ENV=production
ARG SERVER_DEBUG=''
#ARG BRANCH=develop
ARG BRANCH=release-3.5.0 
ARG REACT_APP_DEBUG=''

WORKDIR ${BASEDIR}

RUN apt-get update;DEBIAN_FRONTEND=noninteractive apt-get install -yq git bash jq build-essential python python3-pip openssl libssl-dev pkg-config;apt-get clean

#checkout code
RUN git clone --single-branch --branch ${BRANCH} https://github.com/edumeet/${EDUMEET}.git

#install app dep
WORKDIR ${BASEDIR}/${EDUMEET}/app
RUN yarn install --production=false

#set and build app in producion mode/minified/.
ENV NODE_ENV ${NODE_ENV}
ENV REACT_APP_DEBUG=${REACT_APP_DEBUG}
RUN yarn run build

#install server dep
WORKDIR ${BASEDIR}/${EDUMEET}/server
RUN yarn install --production=false && yarn run build

# create edumeet package 
RUN ["/bin/bash", "-c", "cat <<< $(jq '.bundleDependencies += .dependencies' package.json) > package.json" ]
RUN npm pack

# create edumeet image
FROM node:16-bullseye-slim

# Args:
ARG BASEDIR=/opt
ARG EDUMEET=edumeet
ARG NODE_ENV=production
ARG SERVER_DEBUG=''

WORKDIR ${BASEDIR}

COPY --from=edumeet-builder ${BASEDIR}/${EDUMEET}/server/edumeet-server*.tgz  ${BASEDIR}/${EDUMEET}/server/

WORKDIR ${BASEDIR}/${EDUMEET}/server

RUN tar xzf edumeet-server*.tgz && mv package/* ./ && rm -r package edumeet-server*.tgz

RUN apt-get update;DEBIAN_FRONTEND=noninteractive apt-get install -yq openssl;apt-get clean


# Web PORTS
EXPOSE 80 443 
EXPOSE 40000-49999/udp

## run server 
ENV DEBUG ${SERVER_DEBUG}

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
