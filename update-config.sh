#!/bin/bash
source .env                                                                                                                                                                                
echo "Updating configuration example files from upstream edumeet(${BRANCH}) repository.
See README.md file for details"

curl -o configs/app/config.example.js  https://raw.githubusercontent.com/edumeet/edumeet/${BRANCH}/app/public/config/config.example.js
curl -o configs/server/config.example.js  https://raw.githubusercontent.com/edumeet/edumeet/${BRANCH}/server/config/config.example.js
# for near future use
# curl -o configs/server/config.example.yaml  https://raw.githubusercontent.com/edumeet/edumeet/${BRANCH}/server/config/config.example.yaml

for name in {"app","server"}
do
 if [ ! -f configs/${name}/config.js ]
 then
   echo "Copying ${name} config.example.js to config.js"
   cp configs/${name}/config.example.js configs/${name}/config.js
 fi
done

