#!/bin/bash

# Prepare the Automatic Reverse proxy manager certs folder
echo ">> Source ENV file..."
source .env &>/dev/null

# Prepare the Automatic Reverse proxy manager certs folder
echo ">> Creating /data/certs folder..."
mkdir -p /data/certs &>/dev/null

# Prepare the generic git projects container folder
echo ">> Creating /data/git folder..."
mkdir -p /data/git &>/dev/null

# Clone the referrals spam protection
echo ">> Cloning the referrals spam protection project into /data/git/apache-nginx-referral-spam-blacklist..."
git clone https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist.git /data/git/apache-nginx-referral-spam-blacklist &>/dev/null

# Prepare the generic template container folder
echo ">> Creating /data/tmpl folder..."
mkdir -p /data/tmpl &>/dev/null

# Get the new nginx template for the reverse proxy
echo ">> Getting the nginx template for the reverse proxy which includes referrals spam protection..."
wget -q https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/nginx.tmpl -O /data/tmpl/nginx.tmpl &>/dev/null

# Get the nginx proxy custom configuration
echo ">> Getting the nginx custom proxy configuration..."
wget -q https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/proxy.conf -O /data/tmpl/proxy.conf &>/dev/null

# Prepare the generic vhost container folder
echo ">> Creating /data/vhost folder..."
mkdir -p /data/vhost &>/dev/null

# Install Automatic Reverse proxy manager
echo ">> Running Reverse Proxy docker..."
docker run \
    --restart=always \
    --name=docker-auto-reverse-proxy \
    -d \
    -p 80:80 \
    -p 443:443 \
    -v /usr/share/nginx/html \
    -v /data/certs:/etc/nginx/certs:ro \
    -v /data/tmpl/nginx.tmpl:/app/nginx.tmpl:ro \
    -v /data/tmpl/proxy.conf:/etc/nginx/proxy.conf:ro \
    -v /data/vhost/:/etc/nginx/vhost.d \
    -v /data/git/apache-nginx-referral-spam-blacklist/referral-spam.conf:/etc/nginx/referral-spam.conf:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy:alpine &>/dev/null

# Install the Let's Encrypt Reverse Proxy companion
echo ">> Running Let's Encrypt Reverse Proxy companion..."
docker run \
  --restart=always \
  --name=docker-auto-reverse-proxy-companion \
  -d \
  -v /data/certs:/etc/nginx/certs:rw \
  --volumes-from docker-auto-reverse-proxy \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion &>/dev/null

# Autoupdate Dockers from time to time and cleanup old images
echo ">> Running Docker Auto-Update manager..."
docker run \
  --restart=always \
  --name=docker-autoupdate \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  centurylink/watchtower --cleanup &>/dev/null

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. It's truly suggested to reboot now your system to get everything up and running."
echo "Have a nice day!"
echo "-----------------------------------------------------"
