#!/bin/bash
source .env                                                                                                                                                                                
echo "Updating configuration example files from upstream edumeet(${BRANCH}) repository.
See README.md file for details how to configure"


# Download dockerfiles
# if [ ${LOCALDEVMODE} != 0  ]; then
#   # dev-dockerfile
#   curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETCLIENT}/${BRANCHCLIENT}/Dockerfile-dev" -o "Dockerfile-client" && curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/Dockerfile-dev" -o "Dockerfile-server"
# else
#   # production dockerfile
#   curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETCLIENT}/${BRANCHCLIENT}/Dockerfile" -o "Dockerfile-client" && curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/Dockerfile" -o "Dockerfile-server"
# fi
#

# Update example configurations
# edumeet-client
curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETCLIENT}/${BRANCHCLIENT}/public/config/config.example.js" -o "configs/app/config.example.js"
# edumeet-room-server
curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/server/config/config.example.js" -o "configs/server/config.example.js"
curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/server/config/config.example.json" -o "configs/server/config.example.json"

for confDir in {app,nginx,redis,server}
do
  for exConfFile in $(echo ./configs/${confDir}/*example*)
    do
      confFile=${exConfFile/.example/}
      if [ -f ${confFile} ]
      then
        echo "Config ${confFile} exist, skipping..."
      else
        echo "Creating ${confFile} from ${exConfFile}. Please check configuration parameters!"
        cp ${exConfFile} ${confFile}
      fi
  done
done

# Generate and set Redis password
#
REDIS_PASSWORD=$(openssl rand -base64 32)
echo "Generated Redis password: ${REDIS_PASSWORD}"
# escape sed delimiter (/)
REDIS_PASSWORD=${REDIS_PASSWORD//\//\\/}

echo "setting Redis password in ./configs/redis/redis.conf"
sed -i -r "s/^.?requirepass\ .*/requirepass\ ${REDIS_PASSWORD}/" configs/redis/redis.conf

echo "setting Redis password in ./configs/server/config.json"
sed -i -r "s/(^.*\"password\"\ :).*/\1 \"${REDIS_PASSWORD}\"/" configs/server/config.json

# Update TAG version
#
echo "Updating TAG version in .env file extracted from edumeet version"
VERSION=$(curl -s "https://raw.githubusercontent.com/edumeet/edumeet/${BRANCHSERVER}/server/package.json" | grep version | sed -e 's/^.*:\ \"\(.*\)\",/\1/')
sed -i "s/^.*TAG.*$/TAG=${VERSION}/" .env
echo "Current tag: ${TAG}"

echo "
DONE!

Please see README file for further configuration instructions.

"
