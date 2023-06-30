#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

source .env                                                                                                                                                                                

URL=https://edumeet.vidkonf.einfra.hu/mgmt

ACCESSTOKEN=$(curl "$URL/authentication/" \
  -H 'Content-Type: application/json' \
  --data-binary '{ "strategy": "local", "email": "edumeet-admin@localhost", "password": "supersecret" }' -s | jq -r '.accessToken' )
echo -e "
${GREEN}Step 1. get accessToken : ${NOCOLOR}
$ACCESSTOKEN
"
if [ -z "${ACCESSTOKEN}" ];
then
    echo -e "${RED}ERROR: accessToken emtpy ${NOCOLOR}";
    exit;
fi


# Get tennants 
echo $(curl "$URL/tenants" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN" -s)

# add tennant
echo -e "
${GREEN}Add tenant : ${NOCOLOR}
curl \"$URL/tenants\" \
  -H 'Content-Type: application/json' \
  -H \"Authorization: Bearer $ACCESSTOKEN\" \
  --data-binary '{\"name\":\"dev\"}'
"


# Get fqdn 

echo $(curl "$URL/tenantFQDNs" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN" -s)
#add fqdn
echo -e "
${GREEN}Add fqdn : ${NOCOLOR}
curl \"$URL/tenantFQDNs\" \
  -H 'Content-Type: application/json' \
  -H \"Authorization: Bearer $ACCESSTOKEN\" \
  --data-binary '{\"tenantId\":1,\"fqdn\":\"edumeet.vidkonf.einfra.hu\"}'
"

# Get tenantOAuths

echo $(curl "$URL/tenantOAuths" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN" -s)

echo -e "
${GREEN}Add tenantOAuths : ${NOCOLOR}
curl \"$URL/tenantOAuths\" \
  -H 'Content-Type: application/json' \
  -H \"Authorization: Bearer $ACCESSTOKEN\" \
  --data-binary '{  \"tenantId\":1,\"key\":\"edumeet-dev-client\",\"secret\":\"1MAJARGQM0nYhSmRNDSHCLIgBfuZXkv6\",  \"authorize_url\":\"https://edumeet.vidkonf.einfra.hu/kc/realms/dev/protocol/openid-connect/auth\",\"access_url\":\"https://edumeet.vidkonf.einfra.hu/kc/realms/dev/protocol/openid-connect/token\",\"profile_url\":  \"https://edumeet.vidkonf.einfra.hu/kc/realms/dev/protocol/openid-connect/userinfo\",\"redirect_uri\": \"https://edumeet.vidkonf.einfra.hu/mgmt/oauth/tenant/callback\",\"scope\":\"openid profile email\",\"scope_delimiter\":\" \"}'
"

# get rooms
curl "$URL/rooms" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESSTOKEN"

# add room 
echo -e "
${GREEN}Add room (with the user jwt token): ${NOCOLOR}
curl '"$URL/rooms"' \\
  -H 'Content-Type: application/json' \\
  -H '"Authorization: Bearer $ACCESSTOKEN"' \\
  --data-binary '{ \"name\": \"testroom2\",\"description\": \"testdesc\",\"maxActiveVideos\":4, \"tenantId\":1}'
"
exit;
# for patching 
# curl --request PATCH 