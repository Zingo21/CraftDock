#!/bin/sh

# Ensure the /minecraft directory exists and has the correct permissions
mkdir -p /minecraft
chown -R $(id -u):$(id -g) /minecraft

# Check if you want to clear the Minecraft data directory
if [ "$CLEAR_DATA" = "true" ]; then
    echo "Clearing Minecraft data..."
    rm -rf /minecraft/*
fi

# Copy necessary files to the volume directory if they don't exist
if [ ! -f /minecraft/paper.jar ]; then
    cp /tmp/paper.jar /minecraft/
fi

if [ ! -f /minecraft/eula.txt ]; then
    cp /tmp/eula.txt /minecraft/
fi

# Ensure plugins directory exists and copy plugins if they don't exist
mkdir -p /minecraft/plugins
cp -r /tmp/plugins/* /minecraft/plugins/

# Ensure ops.json file exists and has correct permissions
if [ ! -f /minecraft/ops.json ]; then
    touch /minecraft/ops.json
    chown $(id -u):$(id -g) /minecraft/ops.json
fi

# Create log directory if it doesn't exist
mkdir -p /minecraft/logs

# Start the Minecraft server in a screen session
screen -dmS server java -Xms${MEMORY_SIZE} -Xmx${MEMORY_SIZE} -jar /minecraft/paper.jar nogui > /minecraft/logs/latest.log 2>&1

# Keep the container running and tail the log file
tail -f /minecraft/logs/latest.log