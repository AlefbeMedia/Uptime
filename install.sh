#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
BOLD='\033[1m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

# Check if port 3001 is in use
if lsof -i:3001 > /dev/null; then
    echo -e "${red}Error: Port 3001 is already in use${plain}"
fi

# Loading effect
loading() {
    echo -ne "${yellow}${BOLD}        * ALEFBEMEDIA Uptime Service."
    sleep 1
    echo -ne "\r${yellow}${BOLD}        * ALEFBEMEDIA Uptime Service.."
    sleep 1
    echo -ne "\r${yellow}${BOLD}        * ALEFBEMEDIA Uptime Service...${plain}"
    sleep 1
    echo -ne "\n \n"
}
loading

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo -e "${red}Please Install Docker first >> ${plain}bash <(curl -Ls https://raw.githubusercontent.com/dev-ir/ez-docker/master/main.sh) \n "
    exit 1
fi

echo -e "${green}Docker is Onlie ✅"
sleep 1

# Navigate to root directory
cd ~

# delete AlefbeMedia_uptime Directory
rm -r AlefbeMedia_uptime

# Create and navigate to AlefbeMedia_uptime directory
mkdir -p AlefbeMedia_uptime && cd AlefbeMedia_uptime

# Create docker-compose.yml file
cat <<EOL > docker-compose.yml
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

# Start the Docker service
docker compose up -d

# X-UI check
if ! command -v x-ui &> /dev/null
then
    echo -e "${red}Please Install X-UI Pannel first >> ${plain}bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) \n "
    exit 1
else
x-ui start
echo -e "${yellow}x-ui is installed and the setting is:${plain}"
x-ui settings
fi

