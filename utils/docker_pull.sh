#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

source .env                                                                                                                                                                                

echo -e "
${GREEN}To pull nightly docker images:${NOCOLOR}
${NOCOLOR}

docker pull edumeet/${EDUMEET_MN_SERVER}:${TAG}
docker pull edumeet/${EDUMEET_MGMT_SERVER}:${TAG}

docker pull edumeet/${EDUMEET_SERVER}:${TAG}
docker pull edumeet/${EDUMEET_CLIENT}:${TAG}
"

if [ "$1" == "pull" ]; then     ## GOOD
    echo -e "RUNING COMMANDS:
    "
    docker pull edumeet/${EDUMEET_MN_SERVER}:${TAG}
    docker pull edumeet/${EDUMEET_MGMT_SERVER}:${TAG}
    docker pull edumeet/${EDUMEET_SERVER}:${TAG}
    docker pull edumeet/${EDUMEET_CLIENT}:${TAG}
elif [ "$1" == "push" ]; then     ## GOOD
    echo -e "RUNING COMMANDS:
    "
    docker push edumeet/${EDUMEET_MN_SERVER}:${TAG}
    docker push edumeet/${EDUMEET_MGMT_SERVER}:${TAG}
    docker push edumeet/${EDUMEET_SERVER}:${TAG}
    docker push edumeet/${EDUMEET_CLIENT}:${TAG}

else
    echo -e "${RED}or run ./docker_pull.sh pull
    "
fi
