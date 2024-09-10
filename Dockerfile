# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV MINECRAFT_VERSION 1.21.1
ENV PAPER_BUILD 76
ENV MEMORY_SIZE 2G

# Install packages
RUN apt update && apt install -y openjdk-21-jre-headless curl screen && apt clean

# Create the directory for Minecraft
RUN mkdir -p /minecraft

# Set the working directory
WORKDIR /minecraft

# Download PaperMC
RUN curl -o paper.jar -L https://papermc.io/api/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$PAPER_BUILD/downloads/paper-$MINECRAFT_VERSION-$PAPER_BUILD.jar

# Accept EULA
RUN echo "eula=true" > eula.txt

# Expose port
EXPOSE 25565

# Copy plugins
COPY plugins/ /minecraft/plugins/

# Define a volume for the server data
VOLUME /minecraft

# Start server
CMD java -Xms$MEMORY_SIZE -Xmx$MEMORY_SIZE -jar paper.jar nogui
