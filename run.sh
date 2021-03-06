#!/bin/bash
if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_KEY" ]; then
  error 'Please specify key property'
  exit 1
fi

if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_SECRET" ]; then
  error 'Please specify secret property'
  exit 1
fi

if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_REGION" ]; then
  error 'Please specify region property'
  exit 1
fi
if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_CLUSTER" ]; then
  error 'Please specify cluster property'
  exit 1
fi
if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_DEFINITION" ]; then
  error 'Please specify cluster property'
  exit 1
fi
if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_COUNT" ]; then
    echo '[WARN] No scale container'
fi
if [ ! -n "$WERCKER_INSTALL_CONTAINER_TRANSFORM_COMPOSE_FILE" ]; then
    WERCKER_INSTALL_CONTAINER_TRANSFORM_COMPOSE_FILE="docker-compose.yml"
fi

echo 'install curl, pip, awscli...'
sudo apt-get update && apt-get install -y curl
sudo curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
sudo pip install --upgrade pip enum34
sudo pip install awscli
sudo pip install container-transform
aws --version

echo 'Synchronizing References in apt-get...'
sudo apt-get update

sudo pip install container-transform
sudo pip install awscli

echo 'Synchronizing System Time...'
sudo ntpdate ntp.ubuntu.com

echo 'Configuring based on parameters...'
aws configure set aws_access_key_id $WERCKER_INSTALL_CONTAINER_TRANSFORM_KEY
aws configure set aws_secret_access_key $WERCKER_INSTALL_CONTAINER_TRANSFORM_SECRET
aws configure set default.region $WERCKER_INSTALL_CONTAINER_TRANSFORM_REGION

echo 'register task definition'
aws ecs register-task-definition --family $WERCKER_INSTALL_CONTAINER_TRANSFORM_DEFINITION --container-definitions "$(cat $WERCKER_INSTALL_CONTAINER_TRANSFORM_COMPOSE_FILE | container-transform)"

echo ''
aws ecs run-task --cluster $WERCKER_INSTALL_CONTAINER_TRANSFORM_CLUSTER --task-definition $WERCKER_INSTALL_CONTAINER_TRANSFORM_DEFINITION --count $WERCKER_INSTALL_CONTAINER_TRANSFORM_COUNT

echo 'Done.'

