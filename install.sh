#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
BOLD='\033[1m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}${BOLD}Fatal error: ${yellow} Please run this script with root privilege \n " && exit 1

# delete docker container
CONTAINER_NAME="uptime-kuma"
if command -v docker &> /dev/null
then
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker stop "${CONTAINER_NAME}"
    docker rm "${CONTAINER_NAME}"
  fi
fi


# port selection
default_port=3001
while true; do
  # Prompt the user for input
  read -p "Enter port number [default: $default_port]: " port
  
  # Use default value if no input is provided
  port=${port:-$default_port}
  
  # Check if the port is in use
  if lsof -i :$port > /dev/null; then
    echo -e "${red}Error: Port $port is already in use${plain}"
  else
    echo -e "Using port: $port"
    break
  fi
done

# Loading effect
loading() {
    echo -ne "${yellow}${BOLD}        * ALEFBEMEDIA Uptime Service."
    sleep 1
    echo -ne "\r${yellow}${BOLD}        * ALEFBEMEDIA Uptime Service.."
    sleep 1
    echo -ne "\r${yellow}${BOLD}        * ALEFBEMEDIA Uptime Service...${plain}"
    sleep 1
    echo -ne "\n"
}
loading

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo -e "${red}Docker is Offline ❌"
    sleep 1
    echo -e "${yellow}${BOLD}Installing docker..${plain}"
    interface=$(ip route | grep default | awk '{print $5}')
    resolvectl dns $interface 178.22.122.100 185.51.200.2
    curl -fsSL https://get.docker.com | sh
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
      - "$port:3001"
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
    echo -e "${red}Now Please Install X-UI Pannel >> ${plain}bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)"
fi
echo -e "\n${BOLD}* ALEFBEMEDIA Uptime Service is Online ✅"
server_ip=$(curl -s https://api.ipify.org)
echo -e "${yellow}> Access URL: ${plain}http://${server_ip}:$port \n"
echo -e "${yellow}+ Alefbemedia Telegram Channel: ${plain}https://t.me/+VXskKuUuOBEPUB8i \n"
exit 1
