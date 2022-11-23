#!/bin/bash
source .env                                                                                                                                                                                
echo "Updating configuration example files from upstream edumeet(${BRANCH}) repository.
See README.md file for details how to configure"


# Download dockerfiles
if [ ${LOCALDEVMODE} != 0  ]; then  
  # dev-dockerfile
  curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETCLIENT}/${BRANCHCLIENT}/Dockerfile-dev" -o "Dockerfile-client" && curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/Dockerfile-dev" -o "Dockerfile-server"
else
  # production dockerfile
  curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETCLIENT}/${BRANCHCLIENT}/Dockerfile" -o "Dockerfile-client" && curl -s "https://raw.githubusercontent.com/${REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/Dockerfile" -o "Dockerfile-server"
fi

# client example config
curl -s "https://raw.githubusercontent.com/REPOSITORY}/${EDUMEETCLIENT}/${BRANCHCLIENT}/public/config/config.example.js" -o "configs/app/config.example.js"
# server example config(s)
curl -s "https://raw.githubusercontent.com/REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/server/config/config.example.js" -o "configs/server/config.example.js"
# yaml for 4.0
curl -s "https://raw.githubusercontent.com/REPOSITORY}/${EDUMEETSERVER}/${BRANCHSERVER}/server/config/config.yaml.js" -o "configs/server/config.yaml.js"

