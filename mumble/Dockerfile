FROM debian:jessie
MAINTAINER Vincent Rouille "vincent@speedy37.fr"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install -y mumble-server

COPY mumble-server.ini /config/mumble-server.ini

VOLUME /data /config
EXPOSE 64738 64738/udp

# I had to delay murmurd start a bit, otherwize the service is unable to listen
CMD ["/bin/sh", "-c", "sleep 1 && exec /usr/sbin/murmurd -fg -ini /config/mumble-server.ini"]
