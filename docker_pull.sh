#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

source .env                                                                                                                                                                                

echo -e "
${GREEN}To pull nightly docker images:${NOCOLOR}
${NOCOLOR}

docker pull edumeet/${EDUMEET_MN_SERVER}:${TAG}
docker pull edumeet/${EDUMEET_CLIENT}:${TAG}
docker pull edumeet/${EDUMEET_SERVER}:${TAG}
"

if [ "$1" == "pull" ]; then     ## GOOD
    echo -e "RUNING COMMANDS:
    "
    docker pull edumeet/${EDUMEET_MN_SERVER}:${TAG}
    docker pull edumeet/${EDUMEET_CLIENT}:${TAG}
    docker pull edumeet/${EDUMEET_SERVER}:${TAG}

else
    echo -e "${RED}or run ./docker_pull.sh pull
    "
fi