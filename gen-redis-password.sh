#!/bin/bash
REDIS_PASSWORD=$(openssl rand -base64 32)
echo "Generated Redis password: ${REDIS_PASSWORD}"
# escape sed delimiter (/)
REDIS_PASSWORD=${REDIS_PASSWORD//\//\\/}

echo "setting Redis password in /configs/redis/redis.conf"
sed -i -r "s/_GENERATED_REDIS_PASSWORD_.*/${REDIS_PASSWORD}/" configs/redis/redis.conf

echo "setting Redis password in /configs/server/config.yaml"
sed -i -r "s/_GENERATED_REDIS_PASSWORD_.*/${REDIS_PASSWORD}/" configs/server/config.yaml
