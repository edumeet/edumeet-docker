#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

source .env                                                                                                                                                                                

echo -e "
${GREEN}Step 1.${NOCOLOR}
Updating configuration example files from upstream edumeet(${BRANCHSERVER}) repository.
"
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
        echo -e "Config ${confFile} exist, ${RED}skipping...${NOCOLOR}"
        rm ${exConfFile}  &>/dev/null
      elif [ -f ${exConfFile} ]
      then
        echo -e "Creating ${confFile} from ${exConfFile}. ${RED}Please check configuration parameters!${NOCOLOR}"
        mv ${exConfFile} ${confFile} &>/dev/null
      fi
  done
done

# Generate and set Redis password
#
REDIS_PASSWORD=$(openssl rand -base64 32)
echo -e "

${GREEN}Step 2.${NOCOLOR}
Generating Redis password: ${REDIS_PASSWORD}"
# escape sed delimiter (/)
REDIS_PASSWORD=${REDIS_PASSWORD//\//\\/}

echo -e "setting Redis password in ./configs/redis/redis.conf"
sed -i -r "s/^#?\ ?requirepass\ .*/requirepass\ ${REDIS_PASSWORD}/" configs/redis/redis.conf

echo -e "setting Redis password in ./configs/server/config.json"
sed -i -r "s/(^.*\"password\"\ :).*/\1 \"${REDIS_PASSWORD}\"/" configs/server/config.json

# Update TAG version
#
echo -e "

${GREEN}Step 3.${NOCOLOR}
Updating TAG version in .env file extracted from edumeet version"
VERSION=$(curl -s "https://raw.githubusercontent.com/edumeet/edumeet/${BRANCHSERVER}/server/package.json" | grep version | sed -e 's/^.*:\ \"\(.*\)\",/\1/')
sed -i "s/^.*TAG.*$/TAG=${VERSION}/" .env
echo -e "Current tag: ${RED}${VERSION}${GREEN}"

echo -e "
DONE!

${RED}Please see README file for further configuration instructions.${NOCOLOR}
"
