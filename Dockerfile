FROM node:lts

# Args
ARG BASEDIR=/opt
ARG MM=multiparty-meeting
ARG NODE_ENV=production
ARG SERVER_DEBUG=''

WORKDIR ${BASEDIR}

RUN git clone -b '1.2' https://github.com/havfo/${MM}.git

#install server dep
WORKDIR ${BASEDIR}/${MM}/server

RUN yarn

# install gulp-cli
RUN yarn global add gulp-cli

#install app dep
WORKDIR ${BASEDIR}/${MM}/app
RUN yarn install --production=false

# copy app config
ADD configs/app/config.js config/config.js

# set app in producion mode/minified/.
ENV NODE_ENV ${NODE_ENV}

# package web app
RUN gulp dist

# Web PORTS
EXPOSE 80 443 
EXPOSE 40000-49999/udp


## run server 
ENV DEBUG ${SERVER_DEBUG}

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

