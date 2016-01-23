FROM ubuntu:latest
MAINTAINER Vincent Rouille <vincent@speedy37.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:duplicity-team/daily \
 && apt-get update -y \
 && apt-get -y install duplicity python-paramiko rsync python-pip python-dev build-essential \
 && pip install pyrax

VOLUME /root/.cache/duplicity

CMD ["duplicity", "--help"]
