#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo -e "${red}Please Install Docker first >> ${plain}bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/ez-docker/master/main.sh) \n "
    exit 1
fi

# Navigate to root directory
cd ~

# Create and navigate to AlefbeMedia_uptime directory
mkdir -p AlefbeMedia_uptime && cd AlefbeMedia_uptime

# Create docker-compose.yml file
cat <<EOL > docker-compose.yml
version: '3.8'
# @Alefbemedia Uptime Service for Xray Configs
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    restart: always
    ports:
      - "3001:3001"
    volumes:
      - uptime-kuma:/app/data
volumes:
  uptime-kuma:
EOL

chmod +x docker-compose.yml

# Start the Docker service
docker compose up -d

# Create Xray directory and navigate to it
mkdir -p Xray && cd Xray

# Create configs directory
mkdir -p configs

# Check CPU architecture and download the appropriate Xray version
ARCH=$(uname -m)

if [[ "$ARCH" =~ ^(x86_64|x64|amd64)$ ]]; then
    # Download and unzip Xray for x64
    wget https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-64.zip
    unzip Xray-linux-64.zip
    rm Xray-linux-64.zip geoip.dat geosite.dat LICENSE README.md
elif [[ "$ARCH" =~ ^(armv8*|armv8|arm64|aarch64)$ ]]; then
    # Download and unzip Xray for ARM
    wget https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-arm64-v8a.zip
    unzip Xray-linux-arm64-v8a.zip
    rm Xray-linux-arm64-v8a.zip geoip.dat geosite.dat LICENSE README.md
    touch config.json
    chmod +x config.json
else
    echo -e "${red}Unsupported CPU architecture!"
fi
