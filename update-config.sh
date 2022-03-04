#!/bin/bash
source .env                                                                                                                                                                                
echo "Updating configuration example files from upstream edumeet(${BRANCH}) repository.
See README.md file for details"

curl https://raw.githubusercontent.com/edumeet/edumeet/${BRANCH}/app/public/config/config.example.js -o configs/app/config.example.js 
curl "https://raw.githubusercontent.com/edumeet/edumeet/${BRANCH}/server/config/config.example.{js,json,yaml,toml}" -Z -o "configs/server/config.example.#1" 

