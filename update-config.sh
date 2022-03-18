#!/bin/bash
source .env                                                                                                                                                                                
echo "Updating configuration example files from upstream edumeet(${BRANCH}) repository.
See README.md file for details how to configure"

curl -s "https://raw.githubusercontent.com/${REPOSITORY}/edumeet/${BRANCH}/app/public/config/config.example.js" -o "configs/app/config.example.js"
curl -s "https://raw.githubusercontent.com/${REPOSITORY}/edumeet/${BRANCH}/server/config/config.example.{js,json,yaml,toml}" -Z -o "configs/server/config.example.#1" 

echo "Updating TAG version in .env file extracted from edumeet version"
VERSION=$(curl -s "https://raw.githubusercontent.com/edumeet/edumeet/${BRANCH}/server/package.json" | grep version | sed -e 's/^.*:\ \"\(.*\)\",/\1/')
echo "Current tag: ${TAG}"
sed -i "s/^.*TAG.*$/TAG=${VERSION}/" .env

