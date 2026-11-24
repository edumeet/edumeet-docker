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

# Downloading recommended TLS parameters
if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating development certificate for ${domains[*]} ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
# The certificate names the domains, so it can be trusted explicitly (see below).
san=""
for domain in "${domains[@]}"; do
  if [[ $domain =~ ^[0-9.]+$ || $domain == *:* ]]; then san="$san,IP:$domain"; else san="$san,DNS:$domain"; fi
done
docker compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 30\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=$domains' \
    -addext 'subjectAltName=${san#,}'" certbot
echo

# The management server verifies the certificate of the identity provider. Signing in through
# the Keycloak of this setup (https://$MAIN_DOMAIN/kc) only works if it trusts this certificate.
mkdir -p certs/extra-ca
if cp "$data_path/conf/live/$domains/fullchain.pem" certs/extra-ca/dev-cert.pem; then
  echo "### The certificate is valid for 30 days and was copied to certs/extra-ca/dev-cert.pem."
  echo "### To trust it in the eduMEET services, set in .env:"
  echo "###   NODE_EXTRA_CA_CERTS=/certs/extra-ca/dev-cert.pem"
  echo "### and run: docker compose up -d"
else
  echo "### Could not copy the certificate to certs/extra-ca/dev-cert.pem; copy $data_path/conf/live/$domains/fullchain.pem there by hand." >&2
fi

