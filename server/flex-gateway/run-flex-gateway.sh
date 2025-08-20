#!/bin/bash
# cd to script's directory
cd "$(dirname "$0")"

# Make the logs directory (might be unneeded)
mkdir -p ./logs
echo 'AssetName (aka DNS?) in our registration.yaml:'
cat conf/registration.yaml | grep assetName

docker run \
  --rm \
  -u "$(id -u ec2-user)" \
  -d \
  --name flex-gateway \
  -v "$(pwd)/conf":/usr/local/share/mulesoft/flex-gateway/conf.d \
  -v "$(pwd)/logs":/usr/local/share/mulesoft/flex-gateway/logs \
  -p 8081:8081 \
  mulesoft/flex-gateway
