#!/bin/bash

# Configuration variables
PORTAINER_DOMAIN="portainer.lan"
PORTAINER_NAME="portainer"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Prepare the Mail Server data folder
echo ">> Creating /data/portainer folder..."
mkdir -p /data/portainer &>/dev/null

# Install Portainer
echo ">> Running Portainer..."
docker run \
    --restart=always \
    --name="$PORTAINER_NAME" \
    --privileged \
    -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /data/portainer:/data
    -e "VIRTUAL_HOST=$PORTAINER_DOMAIN" \
    -e "VIRTUAL_PORT=9000" \
    -e "LETSENCRYPT_HOST=$PORTAINER_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    portainer/portainer &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Portainer to start..."
while [ ! $(docker top $PORTAINER_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${PORTAINER_DOMAIN}/"
echo "-----------------------------------------------------"
