# Craftdock

A Minecraft paper server in a docker container

## How to run the server

To download and run the Minecraft server, run:

`docker run -d --name <container-name> -p 25565:25565 -v <host-data-directory>:/minecraft -e MEMORY_SIZE=2G zingo21/craftdock:latest`

This command pulls the image, creates the container, and runs the server with 2GB RAM.

You can change memory with `-e MEMORY_SIZE=4G` (or any valid Java size, for example `3G`).

## Docker Compose

If you prefer Docker Compose, copy from `compose.example.yaml` and adjust it to your needs. If the compose file is placed in a folder, simply run:

`docker compose up -d`

The example includes the same core settings as the `docker run` examples and keeps the common optional features next to them:

- Uncomment `ENABLE_RCON` and `RCON_PASSWORD` if you want to use `docker exec <container-name> mc-cmd ...`.
- You do not need to publish port `25575` just to use `mc-cmd` through `docker exec`; only publish it if an external RCON client needs to connect.
- Uncomment `stdin_open` and `tty` if you want to use `docker attach`.

## Changing server properties

Pass any `server.properties` key as an environment variable using the `SERVER_` prefix — underscores become hyphens and the name is lowercased automatically:

| Environment variable | `server.properties` key | Example value |
| --- | --- | --- |
| `SERVER_MOTD` | `motd` | `My Server` |
| `SERVER_MAX_PLAYERS` | `max-players` | `20` |
| `SERVER_DIFFICULTY` | `difficulty` | `hard` |
| `SERVER_VIEW_DISTANCE` | `view-distance` | `10` |
| `SERVER_GAMEMODE` | `gamemode` | `survival` |

Example:

`docker run -d --name <container-name> -p 25565:25565 -v <host-data-directory>:/minecraft -e SERVER_MOTD="My Server" -e SERVER_MAX_PLAYERS=10 zingo21/craftdock:latest`

These values are written to `server.properties` every time the container starts, so they always reflect what you passed in.

## How to run commands in the minecraft server

### Recommended: `docker exec` + `mc-cmd` (RCON required)

Start the container with RCON enabled:

`docker run -d --name <container-name> -p 25565:25565 -p 25575:25575 -v <host-data-directory>:/minecraft -e ENABLE_RCON=true -e RCON_PASSWORD=<strong-password> -e RCON_PORT=25575 zingo21/craftdock:latest`

Then run commands directly with Docker:

- `docker exec <container-name> mc-cmd op <minecraft-name>`
- `docker exec <container-name> mc-cmd whitelist add <minecraft-name>`
- `docker exec <container-name> mc-cmd say Server restart in 5 minutes`
- `docker exec <container-name> mc-cmd save-all`

This is the preferred command workflow for one-off admin commands and automation.

Notes:

- If `ENABLE_RCON=true` is set without `RCON_PASSWORD`, the container exits with a clear error.
- If you only use `docker exec <container-name> mc-cmd ...`, you can skip publishing `25575` and keep only `-p 25565:25565`.

### Optional: External RCON client

If you prefer an RCON client on your host/network, keep `-p 25575:25575` and use your client of choice.

### Fallback: `docker attach` interactive console (no RCON)

Use this only when you want a live interactive console and do not want RCON.

Important: to type commands via `docker attach`, the container must be created with interactive stdin/tty (`-it`).

Start example (attach-capable):

`docker run -dit --name <container-name> -p 25565:25565 -v <host-data-directory>:/minecraft -e MEMORY_SIZE=2G zingo21/craftdock:latest`

Attach directly to the running server console:

`docker attach --detach-keys="ctrl-d" <container-name>`

Then run commands such as:

- `op <minecraft-name>`
- `deop <minecraft-name>`
- `whitelist add <minecraft-name>`

Detach without stopping the container by pressing `Ctrl+d`.

If the container was started without `-it`, you cannot enable interactive input later; recreate the container with `-dit`.
