#!/bin/bash
REDIS_PASSWORD=$(openssl rand -base64 32)
echo -e "\n  password: $REDIS_PASSWORD" >>./configs/server/config.yaml
echo "requirepass $REDIS_PASSWORD" >> ./configs/redis/redis.conf
