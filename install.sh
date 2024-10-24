#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
BOLD='\033[1m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

# Show Alefbemedia
echo -e "${yellow}${BOLD}ALEFBEMEDIA${plain}"

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

# executable docker-compose.yml file
chmod +x docker-compose.yml

# Start the Docker service
docker compose up -d

# Create Xray directory and navigate to it
mkdir -p Xray && cd Xray

# Create configs directory
mkdir -p configs

# Create config generator file
cat <<EOL > config_generator.sh
#!/bin/bash

# Path to the directory containing your config files
CONFIG_DIR="/root/AlefbeMedia_uptime/Xray/configs"

# Remove config.json if it exists
rm -f config.json

# Count the number of .json files in the directory
configs=$(ls -1q ${CONFIG_DIR}/*.json | wc -l)

# Begin the config.json content
cat <<EOL > config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
EOL

# Loop through each config file and create the inbounds entries
for (( i=1; i<=configs; i++ ))
do
  port=$((100 + i))
  tag="p$i"
  # Create the inbound entry
  cat <<EOL >> config.json
    {
      "tag": "$tag",
      "listen": "172.17.0.1",
      "port": "$port",
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true,
        "ip": "127.0.0.1"
      }
    }$(if [ $i -lt $configs ]; then echo ","; fi)
EOL
done

# Close the inbounds section
cat <<EOL >> config.json
  ],
  "outbounds": [
EOL

# Loop through each config file to create outbounds
for (( i=1; i<=configs; i++ ))
do
  outbound_file="${CONFIG_DIR}/${i}.json"
  tag="\"tag\": \"$i\""

  # Extract the outbound section from the config file and add a tag if not present
  outbound=$(jq '.outbounds[0]' "$outbound_file" | jq ". + {\"tag\": \"$i\"}")

  # Correctly format and append outbound to config.json
  echo "$outbound" | jq -c '.' >> config.json

  # Add a comma after the outbound, except for the last one
  if [ $i -lt $configs ]; then
    echo "," >> config.json
  fi
done

# Close the outbounds section
cat <<EOL >> config.json
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
EOL

# Loop to add routing rules
for (( i=1; i<=configs; i++ ))
do
  cat <<EOL >> config.json
      {
        "inboundTag": "p$i",
        "outboundTag": "$i",
        "type": "field"
      }$(if [ $i -lt $configs ]; then echo ","; fi)
EOL
done

# Close the routing section
cat <<EOL >> config.json
    ]
  }
}
EOL

# Format config.json to be properly indented and save it back as config.json
jq '.' config.json > temp_config.json && mv temp_config.json config.json

# Make the config.json executable
chmod +x config.json

echo -e "${plain}config.json file has been generated."

EOL

# executable config_generator.sh file
chmod +x config_generator.sh

echo -e "${plain}config generator file has been generated."

# Check CPU architecture and download the appropriate Xray version
ARCH=$(uname -m)

if [[ "$ARCH" =~ ^(x86_64|x64|amd64)$ ]]; then
    # Download and unzip Xray for x64
    wget https://github.com/XTLS/xray-core/releases/latest/download/Xray-linux-64.zip
    unzip Xray-linux-64.zip
    rm Xray-linux-64.zip geoip.dat geosite.dat LICENSE README.md
elif [[ "$ARCH" =~ ^(armv8*|armv8|arm64|aarch64)$ ]]; then
    # Download and unzip Xray for ARM
    wget https://github.com/XTLS/xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip
    unzip Xray-linux-arm64-v8a.zip
    rm Xray-linux-arm64-v8a.zip geoip.dat geosite.dat LICENSE README.md
    touch config.json
    chmod +x config.json
else
    echo -e "${red}Unsupported CPU architecture! Xray not downloaded ${plain}"
fi
