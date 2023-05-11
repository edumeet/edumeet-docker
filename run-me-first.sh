#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

source .env                                                                                                                                                                                

echo -e "
${GREEN}Step 1.${NOCOLOR}
Updating configuration example files from upstream ${EDUMEET_SERVER}/${BRANCH_SERVER} repository."
# Update example configurations
# edumeet-client
curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEET_CLIENT}/${BRANCH_CLIENT}/public/config/config.example.js" -o "configs/app/config.example.js"
echo -e "Updating configuration example files from upstream ${EDUMEET_CLIENT}/${BRANCH_CLIENT} repository.
"
# edumeet-room-server
curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEET_SERVER}/${BRANCH_SERVER}/config/config.example.json" -o "configs/server/config.example.json"

for confDir in {app,nginx,server}
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

# Update TAG version
# VERSION=$(curl -s "https://raw.githubusercontent.com/edumeet/${EDUMEET_SERVER}/${BRANCH_SERVER}/package.json" | grep version | sed -e 's/^.*:\ \"\(.*\)\",/\1/')
echo -e "

${GREEN}Step 2.${NOCOLOR}
Updating TAG version in .env file extracted from edumeet version"

#VERSION=4.x-$(date '+%Y%m%d')-nightly
VERSION=$(curl -L --fail -s "https://hub.docker.com/v2/repositories/${REPOSITORY}/${EDUMEET_CLIENT}/tags/?page_size=1000" |	jq '.results | .[] | .name' -r | 	sed 's/latest//' | 	sort --version-sort | tail -n 1 | grep 4)
sed -i "s/^.*TAG.*$/TAG=${VERSION}/" .env
echo -e "Current tag: ${RED}${VERSION}${NOCOLOR}
${GREEN}Step 3.${NOCOLOR}
To get latest images run the following or build it with running \"docker-compose up\":

${RED}
docker pull edumeet/${EDUMEET_MN_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_CLIENT}:${VERSION}
docker pull edumeet/${EDUMEET_SERVER}:${VERSION}
"
echo -e "
${GREEN}Step 4.${NOCOLOR}
In configs/nginx/default.conf change IP :
proxy_pass          http://edumeet.example.com:8000;
-> 
${RED}proxy_pass          http://$(hostname -I | awk '{print $1}'):<port>;
${NOCOLOR}
In configs/server change IP and port:
${RED}\"listenPort\": \"<port>\",
\"listenHost\": \"$(hostname -I | awk '{print $1}')\",
${NOCOLOR}
${GREEN}Step 5.${NOCOLOR}
DONE!
${RED}Please see README file for further configuration instructions.${NOCOLOR}
"
