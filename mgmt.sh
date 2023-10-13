#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

source .env                                                                                                                                                                                
#DOMAIN ,REALM TODO
echo "curl \"$MGMT_URL/authentication/\" \
  -H 'Content-Type: application/json' \
  --data-binary '{ \"strategy\": \"local\", \"email\": \"edumeet-admin@localhost\", \"password\": \"supersecret\" }' -s | jq -r '.accessToken'";

ACCESSTOKEN=$(curl --insecure "$MGMT_URL/authentication/" \
  -H 'Content-Type: application/json' \
  --data-binary '{ "strategy": "local", "email": "edumeet-admin@localhost", "password": "supersecret" }' -s | jq -r '.accessToken' )
echo -e "
${GREEN}Step 1. get accessToken : ${RED}
$ACCESSTOKEN
${NOCOLOR}
"
if [ -z "${ACCESSTOKEN}" ];
then
    echo -e "${RED}ERROR: accessToken emtpy ${NOCOLOR}";
    exit;
fi


# Get tennants 
echo $(curl --insecure "$MGMT_URL/tenants" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN" -s)

# add tennant
echo -e "
${GREEN}Add tenant : ${NOCOLOR}
curl \"$MGMT_URL/tenants\" \
  -H 'Content-Type: application/json' \
  -H \"Authorization: Bearer $ACCESSTOKEN\" \
  --data-binary '{\"name\":\"dev\"}'
"


# Get fqdn 

echo $(curl --insecure "$MGMT_URL/tenantFQDNs" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN" -s)
#add fqdn
echo -e "
${GREEN}Add fqdn : ${NOCOLOR}
curl \"$MGMT_URL/tenantFQDNs\" \
  -H 'Content-Type: application/json' \
  -H \"Authorization: Bearer $ACCESSTOKEN\" \
  --data-binary '{\"tenantId\":1,\"fqdn\":\"${EDUMEET_DOMAIN_NAME}\"}'
"

# Get tenantOAuths

echo $(curl --insecure "$MGMT_URL/tenantOAuths" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN" -s)

echo -e "
${GREEN}Add tenantOAuths : ${NOCOLOR}
curl \"$MGMT_URL/tenantOAuths\" \
  -H 'Content-Type: application/json' \
  -H \"Authorization: Bearer $ACCESSTOKEN\" \
  --data-binary '{  \"tenantId\":1,\"key\":\"edumeet-dev-client\",\"secret\":\"1MAJARGQM0nYhSmRNDSHCLIgBfuZXkv6\",  \"authorize_url\":\"https://${EDUMEET_DOMAIN_NAME}/kc/realms/dev/protocol/openid-connect/auth\",\"access_url\":\"https://${EDUMEET_DOMAIN_NAME}/kc/realms/dev/protocol/openid-connect/token\",\"profile_url\":  \"https://${EDUMEET_DOMAIN_NAME}/kc/realms/dev/protocol/openid-connect/userinfo\",\"redirect_uri\": \"https://${EDUMEET_DOMAIN_NAME}/mgmt/oauth/tenant/callback\",\"scope\":\"openid profile email\",\"scope_delimiter\":\" \"}'
"

# get rooms
curl --insecure "$MGMT_URL/rooms" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN"

# add room 
echo -e "
${GREEN}Add room (with the user jwt token): ${NOCOLOR}
curl '"$MGMT_URL/rooms"' \\
  -H 'Content-Type: application/json' \\
  -H '"Authorization: Bearer $ACCESSTOKEN"' \\
  --data-binary '{ \"name\": \"testroom2\",\"description\": \"testdesc\",\"maxActiveVideos\":4, \"tenantId\":1}'
"
exit;
# for patching 
# curl --request PATCH 