#!/bin/bash

# Wait for configuration file to be available
while [ ! -f "/app/config/homeserver.config.toml" ]; do
    echo "Waiting for configuration file..."
    sleep 1
done

echo "Starting Pubky Homeserver..."
echo "Configuration file found at: /app/config/homeserver.config.toml"

# Start the homeserver with the configuration file
exec /app/pubky-homeserver --config /app/config/homeserver.config.toml