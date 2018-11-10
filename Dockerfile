FROM node:11

# Args
ARG BASEDIR
ARG MM
ARG NODE_ENV
ARG SERVER_DEBUG

WORKDIR ${BASEDIR}

RUN git clone https://github.com/havfo/${MM}.git

#install server dep
WORKDIR ${BASEDIR}/${MM}/server
RUN yarn

# install gulp-cli
RUN yarn global add gulp-cli

#install app dep
WORKDIR ${BASEDIR}/${MM}/app
RUN yarn install --production=false

# copy app config
ADD config/app-config.js config.js

# set app in producion mode/minified/.
ENV NODE_ENV ${NODE_ENV}

# package web app
RUN gulp dist

# Web PORTS
EXPOSE 80 443 
EXPOSE 40000-49999/udp


## run server 
ENV DEBUG ${SERVER_DEBUG}
WORKDIR ${BASEDIR}/${MM}/server
CMD node ${BASEDIR}/${MM}/server/server.js
