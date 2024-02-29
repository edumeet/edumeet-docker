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
while [ -z "$MAIN_DOMAIN" ] || [ $MAIN_DOMAIN == "edumeet.example.com" ]; do
    read -e -p "
UPDATE DOMAIN NAME (edumeet.example.com): " MAIN_DOMAIN
done

sed -i "s/^.*MAIN_DOMAIN=.*$/MAIN_DOMAIN=${MAIN_DOMAIN}/" .env

while [ -z "$MEDIA_DOMAIN" ] || [ $MEDIA_DOMAIN == "edumeet.example.com" ]; do
    read -e -p "
UPDATE MEDIA_DOMAIN (media.edumeet.example.com): " MEDIA_DOMAIN
done

sed -i "s/^.*MEDIA_DOMAIN=.*$/MEDIA_DOMAIN=${MEDIA_DOMAIN}/" .env




while [ -z "$MANAGEMENT_USERNAME" ] || [ $MANAGEMENT_USERNAME == "edumeet-admin@localhost" ]; do
    read -e -p "
UPDATE management-server admin user in mail format (edumeet-admin@localhost): " MANAGEMENT_USERNAME
done

while [ -z $MANAGEMENT_PASSWORD ] || [ $MANAGEMENT_PASSWORD == "supersecret" ]; do
    RECOMMENDED_PW=`tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''`
    read -e -p "
UPDATE management-server admin user (supersecret ->reccommended: ${RECOMMENDED_PW}): " MANAGEMENT_PASSWORD
    if [ -z $MANAGEMENT_PASSWORD ]
    then
        MANAGEMENT_PASSWORD=$RECOMMENDED_PW
    fi
done

sed -i -e "s/edumeet-admin@localhost/${MANAGEMENT_USERNAME}/g" configs/_mgmt_pwchange/202310300000000_migrate.ts
sed -i -e "s/supersecret2/${MANAGEMENT_PASSWORD}/g" configs/_mgmt_pwchange/202310300000000_migrate.ts

sed -i "s/^.*MANAGEMENT_USERNAME=.*$/MANAGEMENT_USERNAME=${MANAGEMENT_USERNAME}/" .env
sed -i "s/^.*MANAGEMENT_PASSWORD=.*$/MANAGEMENT_PASSWORD=${MANAGEMENT_PASSWORD}/" .env


while [ -z "$KEYCLOAK_ADMIN" ] || [ $KEYCLOAK_ADMIN == "edumeet" ]; do
    read -e -p "
UPDATE KEYCLOAK_ADMIN user: " KEYCLOAK_ADMIN
done

while [ -z $KEYCLOAK_ADMIN_PASSWORD ] || [ $KEYCLOAK_ADMIN_PASSWORD == "edumeet" ]; do
    RECOMMENDED_PW=`tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''`
    read -e -p "
UPDATE KEYCLOAK_ADMIN_PASSWORD (edumeet ->reccommended: ${RECOMMENDED_PW}): " KEYCLOAK_ADMIN_PASSWORD
    if [ -z $KEYCLOAK_ADMIN_PASSWORD ]
    then
        KEYCLOAK_ADMIN_PASSWORD=$RECOMMENDED_PW
    fi
done

sed -i "s/^.*KEYCLOAK_ADMIN=.*$/KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN}/" .env
sed -i "s/^.*KEYCLOAK_ADMIN_PASSWORD=.*$/KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}/" .env

regex="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$"


while [ -z "$PGADMIN_DEFAULT_EMAIL" ] || [ $PGADMIN_DEFAULT_EMAIL == "edumeet@edu.meet" ] || [[ ! "$PGADMIN_DEFAULT_EMAIL" =~ $regex ]]; do
    read -e -p "
UPDATE PGADMIN_DEFAULT_EMAIL user: " PGADMIN_DEFAULT_EMAIL
done

while [ -z $PGADMIN_DEFAULT_PASSWORD ] || [ $PGADMIN_DEFAULT_PASSWORD == "edumeet" ]; do
    RECOMMENDED_PW=`tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''`
    read -e -p "
UPDATE PGADMIN_DEFAULT_PASSWORD (supersecret ->reccommended: ${RECOMMENDED_PW}): " PGADMIN_DEFAULT_PASSWORD
    if [ -z $PGADMIN_DEFAULT_PASSWORD ]
    then
        PGADMIN_DEFAULT_PASSWORD=$RECOMMENDED_PW
    fi
done

sed -i "s/^.*PGADMIN_DEFAULT_EMAIL=.*$/PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL}/" .env
sed -i "s/^.*PGADMIN_DEFAULT_PASSWORD=.*$/PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}/" .env

echo -e "

${GREEN}Step 2.${NOCOLOR}
Updating TAG version in .env file extracted from edumeet version"

#VERSION=4.x-$(date '+%Y%m%d')-nightly
VERSION=$(curl -L --fail -s "https://hub.docker.com/v2/repositories/${REPOSITORY}/${EDUMEET_CLIENT}/tags/?page_size=1000&name=stable" |	jq '.results | .[] | .name' -r | 	sed 's/latest//' | 	sort --version-sort | tail -n 1 | grep 4)
sed -i "s/^.*TAG.*$/TAG=${VERSION}/" .env
LISTEN_IP=$(hostname -I | awk '{print $1}')
sed -i "s/^.*LISTEN_IP.*$/LISTEN_IP=${LISTEN_IP}/" .env
EXTERNAL_IP=$(hostname -I | awk '{print $1}')
sed -i "s/^.*EXTERNAL_IP.*$/EXTERNAL_IP=${EXTERNAL_IP}/" .env



echo -e "Current tag: ${RED}${VERSION}${NOCOLOR}
IP set to : ${RED}${LISTEN_IP}${NOCOLOR}
External IP set to : ${RED}${EXTERNAL_IP}${NOCOLOR}
${GREEN}Step 3.${NOCOLOR}
To get latest images run the following or build it with running \"docker-compose up\":

${RED}
docker pull edumeet/${EDUMEET_MN_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_CLIENT}:${VERSION}
docker pull edumeet/${EDUMEET_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_MGMT_SERVER}:${VERSION}
docker pull edumeet/${EDUMEET_MGMT_CLIENT}:${VERSION}

"
ACK=$(ack edumeet.example.com --ignore-file=is:README.md --ignore-file=is:run-me-first.sh --ignore-file=is:gen_cert.sh)
ACK_LOCALHOST=$(ack localhost --ignore-file=is:README.md --ignore-file=is:run-me-first.sh --ignore-file=is:.env  --ignore-file=is:mgmt.sh --ignore-file=is:gen_cert.sh)

echo -e "
${GREEN}Step 4.${NOCOLOR}

Change configs to your desired configuration.
By default (single domain setup):
- configs/server/config.json
  'tls' options shoud be removed when running behind proxy
  'host' shoud be 'http://mgmt:3030',
  'hostname' shoud be your IP:   '${LISTEN_IP}',
- configs/app/config.js
   managementUrl shoud be domain name 'https://${MAIN_DOMAIN}/mgmt'


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


# APP/ CLIENT
if grep -Fq 'localhost' configs/app/config.js
then
    read -e -p "
Do you want to set managementUrl to https://${MAIN_DOMAIN}/mgmt from .env file in app/config.js (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i "/"managementUrl"/c managementUrl: \"https://${MAIN_DOMAIN}/mgmt\","  configs/app/config.js
        echo "done"
    fi
else
    echo "room-client OK"
fi


# MGMT-SERVER
if grep -Fq 'edumeet.example.com' configs/mgmt/default.json 
then
    read -e -p "
Do you want to replace edumeet.example.com domain in management-server config files to ${MAIN_DOMAIN} in mgmt/default.json (recommended)?[Y/n] " YN
    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]]
    then 
        sed -i -e "s/edumeet.example.com/${MAIN_DOMAIN}/g" configs/mgmt/default.json 
        
        echo "done"
    fi
fi
# KEYCLOAK( auth )
if grep -Fq 'edumeet.example.com' configs/kc/dev.json
then
    read -e -p "
Do you want to update Keycloak dev realm to your domain : ${MAIN_DOMAIN} from .env file in kc/dev.json (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i "/"adminUrl"/c \"adminUrl\": \"https://${MAIN_DOMAIN}/mgmt/*\","  configs/kc/dev.json
        sed -i "/"edumeet.example.com"/c \"rootUrl\": \"https://${MAIN_DOMAIN}/\","  configs/kc/dev.json

        echo "done"
    fi
else
    echo "keycloak dev realm OK"
fi
# MGMT-CLIENT
if grep -Fq 'edumeet.example.com' configs/mgmt-client/config.js
then
    read -e -p "
Do you want to set up edumeet-management-client to https://${MAIN_DOMAIN}/cli from .env file in mgmt-client/config.js (recommended)? [Y/n] " YN

    if  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] 
    then 
        sed -i "/"serverApiUrl"/c serverApiUrl: \"https://${MAIN_DOMAIN}/mgmt\","  configs/mgmt-client/config.js
        sed -i "/"hostname"/c hostname: \"https://${MAIN_DOMAIN}\","  configs/mgmt-client/config.js
        echo "done"
    fi
else
    echo "management-client OK"
fi

echo "If you want to generate cert(s) with Let's Encrypt run gen-cert.sh"
echo "You can start the application with gen-cert.sh or docker compose up"




