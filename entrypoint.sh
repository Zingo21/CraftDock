#!/bin/sh

is_numeric() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) return 0 ;;
    esac
}

is_true() {
    case "$1" in
        1|true|TRUE|yes|YES|on|ON) return 0 ;;
        *) return 1 ;;
    esac
}

set_server_property() {
    key="$1"
    value="$2"
    file="/minecraft/server.properties"

    if [ ! -f "$file" ]; then
        touch "$file"
    fi

    escaped_value=$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')
    if grep -q "^${key}=" "$file"; then
        sed -i "s/^${key}=.*/${key}=${escaped_value}/" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

# Ensure the /minecraft directory exists
mkdir -p /minecraft

TARGET_UID="$(id -u)"
TARGET_GID="$(id -g)"

if [ "$(id -u)" -eq 0 ]; then
    TARGET_UID="${PUID:-1000}"
    TARGET_GID="${PGID:-1000}"

    if ! is_numeric "$TARGET_UID"; then
        echo "Invalid PUID '$TARGET_UID'. It must be numeric." >&2
        exit 1
    fi

    if ! is_numeric "$TARGET_GID"; then
        echo "Invalid PGID '$TARGET_GID'. It must be numeric." >&2
        exit 1
    fi

    CURRENT_UID="$(id -u minecraft)"
    CURRENT_GID="$(id -g minecraft)"

    if [ "$TARGET_GID" != "$CURRENT_GID" ]; then
        if getent group "$TARGET_GID" >/dev/null 2>&1; then
            usermod -g "$TARGET_GID" minecraft
        else
            groupmod -o -g "$TARGET_GID" minecraft
        fi
    fi

    if [ "$TARGET_UID" != "$CURRENT_UID" ]; then
        usermod -o -u "$TARGET_UID" minecraft
    fi
fi

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
if [ -d /tmp/plugins ] && [ -n "$(ls -A /tmp/plugins 2>/dev/null)" ]; then
    cp -r /tmp/plugins/* /minecraft/plugins/
fi

# Ensure ops.json file exists and has correct permissions
if [ ! -f /minecraft/ops.json ]; then
    touch /minecraft/ops.json
fi

if is_true "${ENABLE_RCON:-false}"; then
    if [ -z "${RCON_PASSWORD:-}" ]; then
        echo "ENABLE_RCON is true but RCON_PASSWORD is empty." >&2
        exit 1
    fi

    set_server_property "enable-rcon" "true"
    set_server_property "rcon.password" "${RCON_PASSWORD}"
    set_server_property "rcon.port" "${RCON_PORT:-25575}"
fi

# Apply any SERVER_* environment variables to server.properties.
# SERVER_MAX_PLAYERS=20  →  max-players=20
# SERVER_MOTD=Hello      →  motd=Hello
env | grep '^SERVER_' | while read -r line; do
    raw_key="${line%%=*}"
    value="${line#*=}"
    prop_key=$(printf '%s' "${raw_key#SERVER_}" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    set_server_property "$prop_key" "$value"
done

# Create log directory if it doesn't exist
mkdir -p /minecraft/logs

# Run the Minecraft server in the foreground (exec replaces the shell so Java
# becomes PID 1, Docker signals are forwarded correctly, and logs stream to
# docker logs).
if [ "$(id -u)" -eq 0 ]; then
    # Root performs setup work; then transfer ownership before dropping privileges.
    chown -R "${TARGET_UID}:${TARGET_GID}" /minecraft
    exec setpriv --reuid="${TARGET_UID}" --regid="${TARGET_GID}" --clear-groups java -Xms${MEMORY_SIZE} -Xmx${MEMORY_SIZE} -jar /minecraft/paper.jar nogui
fi

exec java -Xms${MEMORY_SIZE} -Xmx${MEMORY_SIZE} -jar /minecraft/paper.jar nogui