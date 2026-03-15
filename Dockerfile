# Use Ubuntu as base image
FROM ubuntu:25.10

# Set environment variables
ENV MINECRAFT_VERSION=1.21.10
ENV PAPER_BUILD=115
ENV MEMORY_SIZE=2G
ENV ENABLE_RCON=false
ENV RCON_PORT=25575

# Full update and upgrade
RUN apt update && apt full-upgrade -y && apt clean

# Install packages
RUN apt update && apt install -y openjdk-21-jre-headless curl python3 && apt clean

# Create an unprivileged user for running the server process.
RUN groupadd --system minecraft && useradd --system --gid minecraft --home-dir /minecraft --shell /usr/sbin/nologin minecraft

# Create the directory for Minecraft
RUN mkdir -p /minecraft && chown -R minecraft:minecraft /minecraft

# Set the working directory
WORKDIR /minecraft

# Download PaperMC
RUN curl -fSL -o /tmp/paper.jar https://api.papermc.io/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$PAPER_BUILD/downloads/paper-$MINECRAFT_VERSION-$PAPER_BUILD.jar

# Accept EULA
RUN echo "eula=true" > /tmp/eula.txt

# Expose server and optional RCON ports
EXPOSE 25565 25575

# Copy plugins
COPY plugins/ /tmp/plugins/

# Define a volume for the server data
VOLUME /minecraft

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
COPY mc-cmd /usr/local/bin/mc-cmd
# Normalize CRLF to LF for reliable execution in Linux containers.
RUN sed -i 's/\r$//' /entrypoint.sh /usr/local/bin/mc-cmd && chmod +x /entrypoint.sh /usr/local/bin/mc-cmd

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
