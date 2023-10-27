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

for confDir in {app,nginx,server,mgmt,mgmt-client}
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
MN_IP=$(hostname -I | awk '{print $1}')
sed -i "s/^.*MN_IP.*$/MN_IP=${MN_IP}/" .env


echo -e "Current tag: ${RED}${VERSION}${NOCOLOR}
IP set to : ${RED}${MN_IP}${NOCOLOR}

${GREEN}Step 3.${NOCOLOR}
To get latest images run the following or build it with running \"docker-compose up\":

${RED}
docker pull edumeet/${EDUMEET_MN_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_CLIENT}:${VERSION}
docker pull edumeet/${EDUMEET_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_MGMT_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_MGMT_CLIENT}:${VERSION}

"
ACK=$(ack edumeet.example.com --ignore-file=is:README.md --ignore-file=is:run-me-first.sh)
ACK_LOCALHOST=$(ack localhost --ignore-file=is:README.md --ignore-file=is:run-me-first.sh --ignore-file=is:.env  --ignore-file=is:mgmt.sh)

echo -e "
${GREEN}Step 4.${NOCOLOR}

Change configs to your desired configuration.
By default (single domain setup):
- configs/server/config.json
  'tls' options shoud be removed when running behind proxy
  'host' shoud be 'http://mgmt:3030',
  'hostname' shoud be your domain name   '${EDUMEET_DOMAIN_NAME}',
- configs/app/config.js
   managementUrl shoud be domain name 'https://${EDUMEET_DOMAIN_NAME}/mgmt'


Change domain in the following files:
${ACK}
${ACK_LOCALHOST}
${GREEN}Step 5.${NOCOLOR}
DONE!
*Dont forget to update cert files.
${RED}Please see README file for further configuration instructions.${NOCOLOR}
"

# Room server
if grep -Fq '"tls":' configs/server/config.json
then
    read -e -p "
Do you want to remove tls option from server/config.json (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i '/\"tls\"/,/}/ d; /^$/d' configs/server/config.json && echo "done"
    fi
else
    echo "room-server will run in proxy mode(http) OK"
fi

if grep -Fq 'localhost' configs/server/config.json
then
    read -e -p "
Do you want to set host configuration to domain name from .env file and docker hostname to mgmt in server/config.json (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i '/"host"/c \"host\": \"http://mgmt:3030\",' configs/server/config.json
        sed -i "/"hostname"/c \"hostname\": \"${EDUMEET_DOMAIN_NAME}\","  configs/server/config.json
        echo "done"
    fi
else
    echo "room-server OK
media-node OK"
fi

# APP/ CLIENT
if grep -Fq 'localhost' configs/app/config.js
then
    read -e -p "
Do you want to set managementUrl to https://${EDUMEET_DOMAIN_NAME}/mgmt from .env file in app/config.js (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i "/"managementUrl"/c managementUrl: \"https://${EDUMEET_DOMAIN_NAME}/mgmt\","  configs/app/config.js
        echo "done"
    fi
else
    echo "room-client OK"
fi


# MGMT-SERVER
if grep -Fq 'edumeet.example.com' configs/mgmt/default.json 
then
    read -e -p "
Do you want to replace edumeet.example.com domain in management-server config files to ${EDUMEET_DOMAIN_NAME} in mgmt/default.json (recommended)?[Y/n] " YN
    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]]
    then 
        sed -i -e "s/edumeet.example.com/${EDUMEET_DOMAIN_NAME}/g" configs/mgmt/default.json 
        
        echo "done"
    fi
fi
# KEYCLOAK( auth )
if grep -Fq 'edumeet.example.com' configs/kc/dev.json
then
    read -e -p "
Do you want to update Keycloak dev realm to your domain : ${EDUMEET_DOMAIN_NAME} from .env file in kc/dev.json (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i "/"adminUrl"/c \"adminUrl\": \"https://${EDUMEET_DOMAIN_NAME}/mgmt/*\","  configs/kc/dev.json
        sed -i "/"edumeet.example.com"/c \"rootUrl\": \"https://${EDUMEET_DOMAIN_NAME}/\","  configs/kc/dev.json

        echo "done"
    fi
else
    echo "keycloak dev realm OK"
fi
# MGMT-CLIENT
if grep -Fq 'edumeet.example.com' configs/mgmt-client/config.js
then
    read -e -p "
Do you want to set up edumeet-management-client to https://${EDUMEET_DOMAIN_NAME}/cli from .env file in mgmt-client/config.js (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i "/"serverApiUrl"/c serverApiUrl: \"https://${EDUMEET_DOMAIN_NAME}/mgmt\","  configs/mgmt-client/config.js
        sed -i "/"hostname"/c hostname: \"https://${EDUMEET_DOMAIN_NAME}\","  configs/mgmt-client/config.js
        echo "done"
    fi
else
    echo "management-client OK"
fi

echo "You can start the application"




