# Use Ubuntu as base image
FROM ubuntu:25.10

# Set environment variables
ENV MINECRAFT_VERSION=1.21.10
ENV PAPER_BUILD=130
ENV MEMORY_SIZE=2G

# Full update and upgrade
RUN apt update && apt full-upgrade -y && apt clean

# Install packages
RUN apt update && apt install -y openjdk-21-jre-headless curl && apt clean

# Create the directory for Minecraft
RUN mkdir -p /minecraft

# Set the working directory
WORKDIR /minecraft

# Download PaperMC
RUN curl -o /tmp/paper.jar -L https://papermc.io/api/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$PAPER_BUILD/downloads/paper-$MINECRAFT_VERSION-$PAPER_BUILD.jar

# Accept EULA
RUN echo "eula=true" > /tmp/eula.txt

# Expose port
EXPOSE 25565

# Copy plugins
COPY plugins/ /tmp/plugins/

# Define a volume for the server data
VOLUME /minecraft

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
# Normalize CRLF to LF for reliable execution in Linux containers.
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
