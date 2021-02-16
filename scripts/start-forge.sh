#!/bin/bash


# Runtime
echo "[SERVER] Checking for runtime"
if [ ! -d ${SERVER_DIR}/runtime ]
then
	echo "[SERVER] Runtime folder not found, creating one"
	mkdir ${SERVER_DIR}/runtime
else
	echo "[SERVER] Runtime folder found"
fi

if [ -z "$(find ${SERVER_DIR}/runtime -name jre*)" ]
then
    	URL="https://download.java.net/java/GA/jdk15.0.2/0d1cfde4252546c6931946de8db48ee2/7/GPL/openjdk-15.0.2_linux-x64_bin.tar.gz"
    	echo "[SERVER] Getting OpenJDK15"
		cd ${SERVER_DIR}/runtime
        wget -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/runtime/jre15.tar.gz "${URL}"
        echo $?
		if [ $? == 0 ]
        then
			echo "[SERVER] Downloaded successful"
		else
			echo "[SERVER] Could not download OpenJDK15. Going to sleep..."
			sleep infinity
		fi
		mkdir ${SERVER_DIR}/runtime/jre15
        tar --directory ${SERVER_DIR}/runtime/jre15 --strip-components=1 -xzf ${SERVER_DIR}/runtime/jre15.tar.gz
        rm -rf ${SERVER_DIR}/runtime/jre15.tar.gz
        sleep 5
else
    echo "[SERVER] Found jre15"
fi


# Executable
echo "[SERVER] Checking for executable"
if [ -f ${SERVER_DIR}/server.jar ]
then
    echo "[SERVER] Found executable"
else
	echo "[SERVER] Could not find executable"
    echo "[SERVER] Getting Forge 1.16.4"
	wget -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/server.jar https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.16.4-35.1.4/forge-1.16.4-35.1.4-installer.jar
    echo $?
    if [ $? == 0 ]
    then
        echo "[SERVER] Download successful"
    else
        echo "[SERVER] Could not download executable. Going to sleep..."
        sleep infinity
    fi
    echo "[SERVER] Installing Forge"
    chmod 777 ${SERVER_DIR}/server.jar
    ${SERVER_DIR}/runtime/jre15/bin/java -jar ${SERVER_DIR}/server.jar --installServer
fi


# Config
# echo "[SERVER] Checking for server properties"
# if [ ! -f ${SERVER_DIR}/server.properties ]
# then
#     echo "[SERVER] Could not find server properties"
#     echo "[SERVER] Getting server properties"
#     if wget https://raw.githubusercontent.com/C4ArtZ/MinecraftForgeServer/master/config/server.properties
#     then
#         echo "[SERVER] Download successful"
#     else
#         echo "[SERVER] Could not download server properties. Going to sleep..."
#         sleep infinity
#     fi
# else
#     echo "[SERVER] Found server properties"
# fi


# Starting server
echo "[SERVER] Starting server"
cd ${SERVER_DIR}
screen -S Minecraft -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/runtime/jre15/bin/java ${EXTRA_JVM_PARAMETERS} -Xmx${XMX}M -Xms${XMS}M -jar ${SERVER_DIR}/server.jar nogui ${GAME_PARAMETERS}
sleep 2


# EULA
if [ ! -f $SERVER_DIR/eula.txt ]
then
	echo "[SERVER] EULA not found. Waiting 30 seconds..."
	sleep 30
fi
if [ "${ACCEPT_EULA}" == "true" ]
then
	if grep -rq 'eula=false' ${SERVER_DIR}/eula.txt; then
    	sed -i '/eula=false/c\eula=true' ${SERVER_DIR}/eula.txt
		echo "[SERVER] EULA accepted. Restarting server"
        sleep 5
        exit 0
    fi
elif [ "${ACCEPT_EULA}" == "false" ]
then
	echo "[SERVER] EULA not accepted. You must accept the EULA to use this server!"
    sleep infinity
else
	echo "[SERVER] Something is wrong with the EULA variable!"
    sleep ininity
fi

# Old logs
echo "[SERVER] Checking for old logs"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2&>/dev/null


# Show logs
echo "[SERVER] Waiting for new logs"
sleep 30
if [ -f ${SERVER_DIR}/logs/latest.log ]; then
	screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
	tail -F ${SERVER_DIR}/logs/latest.log
else
	screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
	tail -f ${SERVER_DIR}/masterLog.0
fi