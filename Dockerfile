FROM debian:latest

RUN apt-get update && \
	apt-get -y install --no-install-recommends screen curl jq unzip wget apt-transport-https && \
    apt-get upgrade -y &&\
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_VERSION=""
ENV GAME_PARAMETERS=""
ENV GAME_PORT=25565
ENV XMX=2048
ENV XMS=1024
ENV EXTRA_JVM_PARAMETERS=""
ENV ACCEPT_EULA="false"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV USER="minecraft"
ENV DATA_PERMISSION=770
ENV MODLOADER="forge"

ADD /scripts/ /opt/scripts/

RUN mkdir $DATA_DIR && \
    mkdir $SERVER_DIR && \
    useradd -d $DATA_DIR -s /bin/bash $USER && \
    chown -R $USER $DATA_DIR && ulimit -n 2048 && chmod -R 770 /opt/scripts/

ENTRYPOINT ["/opt/scripts/start.sh"]
