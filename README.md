# Craftdock

## Run the server

To download and run the minecraft server, run `docker run -d -p 25565:25565 -v ~/<data-directory-on-host>:/minecraft -e MEMORY_SIZE=4G --name <container-name> zingo21/craftdock:latest`

## How to make a user a server OP or run any commands in the minecraft server

Attach to the docker container using `docker exec -it <container-name> /bin/bash`
To get to the CLI of the minecraft server, use `screen -r server`

You can alternatively go directly to the CLI by doing `docker exec -it <container-name> screen -r server`and execute commands.

From here on, you can now execute commands on the minecraft server

To detach from the screen session use `CTRL + A` then `CTRL + D`

This will make sure that next time you want to attach to the container and execute commands on the minecraft server, you wil be able to use the screen command again.
