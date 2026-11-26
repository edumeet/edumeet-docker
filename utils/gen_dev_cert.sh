#!/bin/bash

if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
fi

# Load existing .env file if it exists
source .env

# Define other variables
echo '$MAIN_DOMAIN' $MAIN_DOMAIN '$MEDIA_DOMAIN' $MEDIA_DOMAIN
domains=($MAIN_DOMAIN $MEDIA_DOMAIN)
rsa_key_size=4096
data_path="./certbot"

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains ! Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

# Recommended TLS parameters from Certbot. Each file is checked for text it must
# contain, so an error page saved by a failed download is replaced, and a good
# file is never overwritten.
certbot_src="https://raw.githubusercontent.com/certbot/certbot/main/certbot/src/certbot"
get_tls_file() { # <file name> <text it must contain> <URL>
  local file="$data_path/conf/$1"
  grep -q -- "$2" "$file" 2>/dev/null && return 0
  echo "### Downloading $1 ..."
  mkdir -p "$data_path/conf"
  if curl -fsSL "$3" -o "$file.tmp" && grep -q -- "$2" "$file.tmp"; then
    mv "$file.tmp" "$file"
  else
    rm -f "$file.tmp"
    echo "Error: could not download $1 from $3" >&2
    exit 1
  fi
}
get_tls_file options-ssl-nginx.conf "ssl_protocols" "$certbot_src/_internal/plugins/nginx/tls_configs/options-ssl-nginx.conf"
get_tls_file ssl-dhparams.pem "BEGIN DH PARAMETERS" "$certbot_src/ssl-dhparams.pem"
echo

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

