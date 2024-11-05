#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
BOLD='\033[1m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

# delete docker container
if [ "$(docker ps -a -q -f name=uptime-kuma)" ]; then
  docker stop uptime-kuma
  docker rm uptime-kuma
fi

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
    interface=$(ip route | grep default | awk '{print $5}')
    resolvectl dns $interface 178.22.122.100 185.51.200.2
    #curl -fsSL https://get.docker.com | sh
    resolvectl dns $interface 8.8.8.8 8.8.4.4
fi

echo -e "${green}Docker is Onlie ✅"
sleep 1

# Navigate to root directory
cd ~

# delete AlefbeMedia_uptime Directory
if [ -d "AlefbeMedia_uptime" ]; then
rm -r AlefbeMedia_uptime
fi

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
    echo -e "\n${red}Now Please Install X-UI Pannel >> ${plain}bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) \n "
else
x-ui start
echo -e "${yellow}x-ui is installed and the setting is:${plain}"
x-ui settings
fi
echo -e "${BOLD}* ALEFBEMEDIA Uptime Service is Online ✅"
server_ip=$(curl -s https://api.ipify.org)
echo -e "${yellow}> Access URL: ${plain}http://${server_ip}:3001 \n \n"
exit 1
