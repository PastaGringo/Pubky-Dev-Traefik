#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art
echo -e "${BLUE}"
cat << "EOF"
██████╗ ██╗   ██╗██████╗ ██╗  ██╗██╗   ██╗    ████████╗██████╗  █████╗ ███████╗███████╗██╗██╗  ██╗
██╔══██╗██║   ██║██╔══██╗██║ ██╔╝╚██╗ ██╔╝    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║██║ ██╔╝
██████╔╝██║   ██║██████╔╝█████╔╝  ╚████╔╝        ██║   ██████╔╝███████║█████╗  █████╗  ██║█████╔╝ 
██╔═══╝ ██║   ██║██╔══██╗██╔═██╗   ╚██╔╝         ██║   ██╔══██╗██╔══██║██╔══╝  ██╔══╝  ██║██╔═██╗ 
██║     ╚██████╔╝██████╔╝██║  ██╗   ██║          ██║   ██║  ██║██║  ██║███████╗██║     ██║██║  ██╗
╚═╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝
EOF
echo -e "${NC}"

echo -e "${GREEN}=== Pubky-Dev-Traefik Deployment Wizard ===${NC}"
echo -e "${YELLOW}This script will help you configure and deploy your Pubky stack with Traefik.${NC}"
echo ""

# Function to validate domain format
validate_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            if [[ $i -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Check if .env file exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}Found existing .env file. Do you want to reconfigure? (y/N)${NC}"
    read -r reconfigure
    if [[ ! $reconfigure =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Using existing configuration. Starting deployment...${NC}"
        docker-compose up -d
        exit 0
    fi
fi

# Domain Configuration
echo -e "${BLUE}=== Domain Configuration ===${NC}"
while true; do
    echo -e "${YELLOW}Enter your domain name (e.g., example.com):${NC}"
    read -r domain
    if validate_domain "$domain"; then
        break
    else
        echo -e "${RED}Invalid domain format. Please try again.${NC}"
    fi
done

echo -e "${YELLOW}Enter subdomain for the app (default: app):${NC}"
read -r subdomain_app
subdomain_app=${subdomain_app:-app}

echo -e "${YELLOW}Enter subdomain for homeserver (default: homeserver):${NC}"
read -r subdomain_homeserver
subdomain_homeserver=${subdomain_homeserver:-homeserver}

# SSL Configuration
echo -e "${BLUE}=== SSL Configuration ===${NC}"
while true; do
    echo -e "${YELLOW}Enter your email for Let's Encrypt SSL certificates:${NC}"
    read -r ssl_email
    if validate_email "$ssl_email"; then
        break
    else
        echo -e "${RED}Invalid email format. Please try again.${NC}"
    fi
done

# Server Configuration
echo -e "${BLUE}=== Server Configuration ===${NC}"
while true; do
    echo -e "${YELLOW}Enter your server's public IP address:${NC}"
    read -r public_ip
    if validate_ip "$public_ip"; then
        break
    else
        echo -e "${RED}Invalid IP address format. Please try again.${NC}"
    fi
done

# Admin Configuration
echo -e "${BLUE}=== Admin Configuration ===${NC}"
echo -e "${YELLOW}Enter admin password for homeserver (default: admin):${NC}"
read -r admin_password
admin_password=${admin_password:-admin}

# Network Configuration
echo -e "${YELLOW}Enter Docker network name (default: pubky-network):${NC}"
read -r docker_network
docker_network=${docker_network:-pubky-network}

# Create .env file
echo -e "${GREEN}Creating .env file...${NC}"
cat > .env << EOF
# Domain Configuration
DOMAIN=$domain
SUBDOMAIN_APP=$subdomain_app
SUBDOMAIN_HOMESERVER=$subdomain_homeserver

# SSL Configuration
SSL_EMAIL=$ssl_email

# Homeserver Configuration
HOMESERVER_PUBLIC_IP=$public_ip
HOMESERVER_ADMIN_PASSWORD=$admin_password

# Network Configuration
DOCKER_NETWORK=$docker_network
EOF

# Update homeserver configuration
echo -e "${GREEN}Updating homeserver configuration...${NC}"
sed -i.bak "s/public_ip = \".*\"/public_ip = \"$public_ip\"/g" pubky-homeserver/config/homeserver.config.toml
sed -i.bak "s/admin_password = \".*\"/admin_password = \"$admin_password\"/g" pubky-homeserver/config/homeserver.config.toml

# Create acme.json with correct permissions
echo -e "${GREEN}Setting up SSL certificate storage...${NC}"
touch traefik/acme.json
chmod 600 traefik/acme.json

# Summary
echo -e "${GREEN}=== Configuration Summary ===${NC}"
echo -e "${BLUE}Domain:${NC} $domain"
echo -e "${BLUE}App URL:${NC} https://$subdomain_app.$domain"
echo -e "${BLUE}Homeserver URL:${NC} https://$subdomain_homeserver.$domain"
echo -e "${BLUE}SSL Email:${NC} $ssl_email"
echo -e "${BLUE}Public IP:${NC} $public_ip"
echo -e "${BLUE}Admin Password:${NC} $admin_password"
echo -e "${BLUE}Docker Network:${NC} $docker_network"
echo ""

# Confirmation
echo -e "${YELLOW}Do you want to start the deployment now? (Y/n)${NC}"
read -r start_deployment
if [[ ! $start_deployment =~ ^[Nn]$ ]]; then
    echo -e "${GREEN}Starting deployment...${NC}"
    
    # Create Docker network if it doesn't exist
    docker network create $docker_network 2>/dev/null || true
    
    # Start services
    docker-compose up -d
    
    echo -e "${GREEN}=== Deployment Complete! ===${NC}"
    echo -e "${BLUE}Your services are starting up. Please wait a few minutes for SSL certificates to be generated.${NC}"
    echo -e "${BLUE}App URL:${NC} https://$subdomain_app.$domain"
    echo -e "${BLUE}Homeserver URL:${NC} https://$subdomain_homeserver.$domain"
    echo ""
    echo -e "${YELLOW}To check the status of your services:${NC}"
    echo -e "${BLUE}docker-compose ps${NC}"
    echo ""
    echo -e "${YELLOW}To view logs:${NC}"
    echo -e "${BLUE}docker-compose logs -f${NC}"
    echo ""
    echo -e "${YELLOW}To generate a signup token:${NC}"
    echo -e "${BLUE}./generate_signup_token.sh${NC}"
else
    echo -e "${YELLOW}Configuration saved. You can start the deployment later with:${NC}"
    echo -e "${BLUE}docker-compose up -d${NC}"
fi