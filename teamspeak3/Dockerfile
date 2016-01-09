FROM debian:jessie
MAINTAINER Vincent Rouille "vincent@speedy37.fr"

RUN apt-get update -y
 && apt-get upgrade -y
 && apt-get install wget -y

ENV TS3_VERSION 3.0.11.4
ENV TS3_DIR /opt/teamspeak3-server
RUN wget -O \
         /tmp/teamspeak-server.tar.gz \
         http://dl.4players.de/ts/releases/$TS3_VERSION/teamspeak3-server_linux-amd64-$TS3_VERSION.tar.gz
RUN tar -xf /tmp/teamspeak-server.tar.gz -C /opt \
 && mv /opt/teamspeak3-server_linux-amd64 $TS3_DIR

VOLUME /data

RUN ln -s /data/ts3server.sqlitedb $TS3_DIR/ts3server.sqlitedb \
 && ln -s /data/files $TS3_DIR/files \
 && ln -s /data/licensekey.dat $TS3_DIR/licensekey.dat

EXPOSE 9987/udp 10011 30033

CMD ["/opt/teamspeak3-server/ts3server_minimal_runscript.sh"]
