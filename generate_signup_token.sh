#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Pubky Homeserver Signup Token Generator ===${NC}"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found. Please run deploy.sh first.${NC}"
    exit 1
fi

# Source environment variables
source .env

# Check if homeserver is running
if ! docker-compose ps pubky-homeserver | grep -q "Up"; then
    echo -e "${RED}Error: Pubky homeserver is not running. Please start it first with:${NC}"
    echo -e "${BLUE}docker-compose up -d${NC}"
    exit 1
fi

echo -e "${YELLOW}Generating signup token...${NC}"
echo ""

# Generate signup token using the homeserver API
TOKEN_RESPONSE=$(docker-compose exec -T pubky-homeserver curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${HOMESERVER_ADMIN_PASSWORD}" \
    http://127.0.0.1:8080/admin/signup-token)

if [ $? -eq 0 ] && [ ! -z "$TOKEN_RESPONSE" ]; then
    echo -e "${GREEN}Signup token generated successfully!${NC}"
    echo -e "${BLUE}Token:${NC} $TOKEN_RESPONSE"
    echo ""
    echo -e "${YELLOW}You can use this token to register new users on your homeserver.${NC}"
    echo -e "${YELLOW}Homeserver URL:${NC} https://${SUBDOMAIN_HOMESERVER}.${DOMAIN}"
else
    echo -e "${RED}Error: Failed to generate signup token.${NC}"
    echo -e "${YELLOW}Please check the homeserver logs:${NC}"
    echo -e "${BLUE}docker-compose logs pubky-homeserver${NC}"
    exit 1
fi