#!/bin/bash
echo "[SERVER] Checking if UID: ${UID} matches user"
usermod -u ${UID} ${USER}
echo "[SERVER] Checking if GID: ${GID} matches user"
usermod -g ${GID} ${USER}
echo "[SERVER] Setting umask to ${UMASK}"
umask ${UMASK}

chown -R ${UID}:${GID} /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}

term_handler() {
	screenpid="$(su $USER -c "screen -list | grep "Detached" | grep "Minecraft" | cut -d '.' -f1")"
	su $USER -c "screen -S Minecraft -X stuff 'stop^M'" >/dev/null
	tail --pid="$(pidof java)" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM

echo "[SERVER] Checking for Modloader"
echo "${MODLOADER}"
if [["{$MODLOADER}" = "forge"]]
then
    echo "[SERVER] Modloader 'forge' was selected."
    su ${USER} -c "/opt/scripts/start-forge.sh" &
    killpid="$!"
elif [[$MODLOADER = "fabric"]]
then
    echo "[SERVER] Modloader 'fabric' was selected."
    su ${USER} -c "/opt/scripts/start-fabric.sh" &
    killpid="$!"
else
    echo "[SERVER] No modloader selected. Going to sleep..."
    sleep infinity
fi